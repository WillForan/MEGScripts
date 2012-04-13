function [ data ] = EOGExtractSaccades(subj_id, Inputdata)
% This function is will extract saccades from EOG data. This function is
% built on ILAB algorithms that will detect then extract saccades from 
% ASL eye trackers.
%
%   Usage:
%   [ data ] = EOGExtractSaccades(subj_id, Inputdata)
%   
%   Inputs:
%           subj_id = is the subject id
%           Inputdata = is the data from MEG_EOG_to_cm, will be
%           subjid_anti_EOG_data.mat
%
%   outputs:
%           Will be saved to subjid_anti_DATE_EOG_data.mat
%           in each session structure, there will be a 
%           saccadeTable - table of list of unfiltered saccades, onset time must be 
%           after the PrepPeriod that and free of eye blink artifacts
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION - written by David Montez, from original ILAB library
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function will return a list of saccades and information about them
% as calculated from the data contained in the PlotParms ILAB variable.
% The method is as follows:
% 1) Loop through PlotParm data in trial-sized chunks.
%
% 2) Find upward and downward inflection points in the trial data.
%
% 3) Filter the list of inflection (2nd derivative) points as follows:
%       -Negative inflection points (Peaks) need to have a velocity greater
%        than the velocity threshold
%       -Positive inflection points (Valleys) need to have a velocity less
%        than the velocity threshold
%
% 4) Loop through the list of negative inflection points (Peaks)
%
% 5) Calculate saccadic reaction time threshold (usually 15% of velocity peak)
%
% 6) Use Gitelman's method of searching forward and backward to find the
%    sample point at which the velocity falls below this threshold value
%--> OR the sample point is a positive inflection point that lies below
%    the velocity threshold.  This method resolves some issues with saccade
%    detection in some noisy data, as well as an issue with saccades not
%    being detected when using the time window method.  It also allows for
%    the user to get a count of local maxima that occur during a saccade in
%    which multiple maxima and minima occur, but the velocity timecourse
%    never falls below the velocity threshold.
%         
%
% NOTE
%
%   This function was written by ***David Montez the Great!!!!***, 
%   modified by Kai for EOG scoring
%   Last update: 3.14.2012

%% setup variables
% load EOG data
load(Inputdata);

%loop through runs
runs = 1:1:size(data,2);

for run = runs
    disp(['********* PROCESSING Run ' num2str(run)]);
    
    % Variables
    aquisitionInterval = (1/data{run}.sr);    % Eye-tracker acquisition interval
    SRTPercent = 0.15;                      % Percent of peak velocity that define saccade start and end points
    minVelThresh = 40;                      % Absolute minimum angular velocity of a saccade
    minSacccadeAmplitude = 8 ;             % Minimum saccade amplitude in degrees, 
                                           % I purposely set this to a high threshold becasue of EOG's noisyness.
    STDTHRESH = 1.5;
    BlinkThreshold = inf; %Threshold of removing eyeblink artifacts, unit in Z
    BlinkThresholdLowBound = -inf; %This part was changed to inf after ICA denoising was implemented.
    data{run}.saccadeTable = [];                      % Initialize the output variable
    saccadeCount = 0;                       % A counter for the total number of saccades in the dataset
    
    %% extract eye data, remove noisy data points, calculate velocity
    % Get the data from the experiment range
    experimentData = [data{run}.horizontal_position',zscore(data{run}.raw_vertical_position')];
    fprintf('\n\n ****** There are %d samples in this dataset ****** \n', size(experimentData,1))
    
    % Calculate Velocity
    % Keep the velocity vector the same length as the position vector so
    % that the indices coincide with one another.  This done by duplicating
    % the initial velocity point
    xVel = CalculateAngularVelocity(experimentData, aquisitionInterval, data{run}.screen_distance);
    
    % Convert from angular velocity in radians to angular velocty in
    % degrees
    xVel = xVel * (180/pi);
    %yVel = yVel * (180/pi);
    
    %absVel = sqrt(xVel.^2 + yVel.^2);
    absXVel = abs(xVel);
    %absYVel = abs(yVel);
    absVel = absXVel; %ONLY use X velocity for EOG
    
    
    % Get a logical index of samples where the signal is out of range
    % FOR EOG, here we can set eye blink threshold for vertical recordings,
    % which already converted to Z.
    %experimentData = [data{run}.horizontal_position',zscore(data{run}.raw_vertical_position')];
    %outOfBoundsLogical = experimentData(:,2) < BlinkThresholdLowBound | ...
    %    experimentData(:,2) > BlinkThreshold;

    % Get a logical vector that stores the locations of NaN data
    experimentNans = isnan(experimentData);
    
    % get a logical index of samples that fail either or both the pupil or
    % boundary test
    %badSampleLogical = outOfBoundsLogical | pupilZeroLogical;
    
    % Calculate the acceleration of the absolute velocity.  This wll be
    % used to find the velocity peaks for the saccades.
    Acc = diff(absVel);
    Acc = [Acc(1,1);Acc];
    
    % We care about the indices that switch from positive or zero
    % acceleration to negetive acceleration.  So get just the sign of the
    % instantaneous acceleration, counting the zeros the same as the
    % negatives. Think of the next few steps as as a method of finding
    % inflection points in discreet data
    sgnAcc = sign(Acc);
    
    % Create a list of inflection points
    negAcc = sgnAcc == 0 | sgnAcc == -1;
    negOffsetAcc = [ negAcc(2:end); negAcc(end,1)];
    negChangePointsAcc = ( negAcc ~=  negOffsetAcc);
    
    posAcc = sgnAcc == 1;
    posOffsetAcc = [posAcc(2:end);posAcc(end,1)];
    posChangePointsAcc = (posAcc ~= posOffsetAcc);
    
    % Filter out inflection points that are 'valleys', we only care about
    % peaks
    saccadePeaks = (((sgnAcc .* negChangePointsAcc ) == 1) & ...
        absVel >= minVelThresh);
    saccadeValleys = (((sgnAcc .* posChangePointsAcc) == -1) & ...
        absVel <= minVelThresh);
    
    
    %% remove trials that have eye blinks
    %triggerCodes = data{run}.trigger_times;
    VectorsToRemove=[];
    for i=1:size(data{run}.trigger_times,2)
        
        startIndex = data{run}.trigger_times(i) - data{run}.pre_stim*data{run}.sr;
        endIndex = data{run}.trigger_times(i); % we don't want blinks at prep time
        %endIndex = triggerCodes(i) + data{run}.post_stim*data{run}.sr;
        trialData = experimentData(startIndex:endIndex,2);

        if any(trialData(:)>BlinkThreshold)
            VectorsToRemove=[VectorsToRemove,i];
            fprintf('\n\t ******* ATTENTION!! Removed trial #%d because of eyeblinks ******* \n\n', i)
            continue
        end
        
        if any(trialData(:)<BlinkThresholdLowBound)
            VectorsToRemove=[VectorsToRemove,i];
            fprintf('\n\t ******* ATTENTION!! Removed trial #%d because of eyeblinks ******* \n\n', i)
            continue
        end
    end
    data{run}.good_trigger_times=data{run}.trigger_times;
    data{run}.good_trigger_values=data{run}.trigger_values;
    data{run}.good_trigger_times(VectorsToRemove)=[];
    data{run}.good_trigger_values(VectorsToRemove)=[];
    
    %% sorting saccade peaks to generate saccade table
    for i=1:size(data{run}.good_trigger_times,2)
        
        startIndex = data{run}.good_trigger_times(i);
        endIndex = startIndex + data{run}.post_stim*data{run}.sr;
        
        % Reset the trial saccade counter every trial
        trialSaccadeCount = 0;
        
        % Create a binary mask for samples that lie within this trial
        sampleInTrial = zeros(size(experimentData,1),1);
        sampleInTrial(startIndex:endIndex) = 1;
        
        trialSaccadePeaks = sampleInTrial & saccadePeaks;
        
        if any(trialSaccadePeaks)
            
            % Get a list of peak velocity indices
            trialSaccadePeakIndices = find(trialSaccadePeaks);
            
            % Initialize a variable to keep track of the end point of saccades
            % found as we loop through the data.
            previouSaccadeEndIndex = 0;
            
            for j=1:size(trialSaccadePeakIndices)    
                
                
                % Get the index of the peak from the list
                peakIndex = trialSaccadePeakIndices(j);
                absPeakXVel = absXVel(peakIndex);            
                
                
                %%% THIS PART IS DAVID"S EXPERIMENTAL WINDWO ESTIMATION to
                %%% get a trial threshold. 
                % Get the indicies for a context window centered (if possible around)
                % the peak index.
                [contextStart, contextEnd] = GetContextWindow(data{run}.sr,experimentData,peakIndex,1.5);
                % Calculate the mean and standard deviation of the eye movement
                % velocity for this subject within the bounds of the context
                % window. Only use samples where complete data exisits.
                
                % Get the velocities within the context window
                xVelRange = xVel(contextStart:contextEnd);
                %yVelRange = yVel(contextStart:contextEnd);
                % Filter out bad data points
                %xVelRange = xVelRange(~badSampleLogical(contextStart:contextEnd));
                %yVelRange = yVelRange(~badSampleLogical(contextStart:contextEnd));
                % Calculate the mean and stds of the absolute values of the velocities
                %absXVelRange = abs(xVelRange);
                %absYVelRange = abs(yVel(~badSampleLogical));
                
                meanXVel = nanmean(xVelRange);
                %meanYVel = nanmean(yVelRange);
                
                %maxXVel = max(absXVelRange);
                %maxYVel = max(absYVelRange);
                
                stdXVel = std(xVelRange);
                %stdYVel = std(yVelRange);
                
                % Calculate the saccade velocity thresholds for the data range
                % within this context window
                xVelThresh = meanXVel + STDTHRESH * stdXVel; % a saccade must exceed 1 stdev.
                % This is a rather low threshold because of EOG's low SNR
                % yVelThresh = meanYVel + 1 * stdYVel;
                
                
                if peakIndex > previouSaccadeEndIndex  && ...
                        ((absPeakXVel >= xVelThresh) )
                    %((absPeakXVel >= xVelThresh))
                    
                    %((absPeakXVel >= xVelThresh) || (absPeakXVel >= 40))
                    % this option will filter saccades greater than 1.5 std or
                    % greater than 40 degrees
                    
                    % Verifies that this peak has not already been accounted
                    % for in the range of a previous saccade
                    
                    %   ((absPeakXVel >= xVelThresh))
                    searchIndex = trialSaccadePeakIndices (j);
                    SRTCutoff = absVel(peakIndex) * SRTPercent;
                    
                    % Using Gitelmann's method, search backward and forward to find
                    % the index where the velocity is SRTPercent of the peak or we
                    % hit a below threshold inflection point
                    
                    % Backward search
                    while searchIndex > 1 && ...
                            searchIndex > previouSaccadeEndIndex && ...
                            absVel(searchIndex) >= SRTCutoff && ...
                            saccadeValleys(searchIndex) ~= 1
                        
                        searchIndex = searchIndex - 1;
                        
                    end
                    
                    saccadeStartIndex = searchIndex;
                    
                    % Forward search
                    searchIndex = trialSaccadePeakIndices(j);
                    while searchIndex < size(experimentData,1) && ...
                            absVel(searchIndex) >= SRTCutoff && ...
                            saccadeValleys(searchIndex) ~= 1
                        
                        % If, while searching forward, we come across another
                        % velocity peak, absorb it into this saccades range and
                        % recalculate SRTPercent
                        if saccadePeaks(searchIndex) == 1
                            SRTCutoff = absVel(searchIndex) * SRTPercent;
                        end
                        searchIndex = searchIndex + 1;
                    end
                    
                    saccadeEndIndex = searchIndex;
                    previouSaccadeEndIndex = searchIndex;
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % GENERATE SACCADE STATS FOR OUTPUT
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Get the velocity data for this saccade
                    %saccadeRangeVel = absVel(saccadeStartIndex:saccadeEndIndex,1);
                    % Calculate the normed direction of the saccade(unit vector)
                    saccadeDirection = experimentData(saccadeEndIndex,1) - experimentData(saccadeStartIndex,1);
                    saccadeDirection = saccadeDirection/norm(saccadeDirection);
                    % Increment the total saccade and trial saccade counters
                    saccadeCount = saccadeCount + 1;
                    trialSaccadeCount = trialSaccadeCount + 1;                                       
                    
                    % Get total angular distance travelled during this saccade
                    dTheta = CalculateAngularAmplitude(experimentData(saccadeStartIndex:saccadeEndIndex,1:2), ...
                        data{run}.screen_distance);
                    saccadeAmplitude = sqrt(dTheta^2)  * (180/pi);
                    
                    % Check to see the the saccade begins with Nans, if so,
                    % latency cannot be calculated
                    if saccadeStartIndex > 1
                        if experimentNans(saccadeStartIndex-1,1) == 1
                            saccadeLatency = NaN;
                        else
                            saccadeLatency = (saccadeStartIndex - startIndex) * aquisitionInterval  ;
                            
                            % check latency to remove fast express saccades
                            if saccadeLatency < 100/1000
                                continue
                            end
                        end
                    else
                        saccadeLatency = 1;
                    end
                                       
                    saccadeEntry = [i, ...
                        data{run}.good_trigger_times(i), ...
                        data{run}.good_trigger_values(i), ...
                        saccadeLatency,          ...
                        saccadeAmplitude,        ...
                        saccadeDirection];
             
                    if saccadeAmplitude >= minSacccadeAmplitude
                        data{run}.saccadeTable = [data{run}.saccadeTable; saccadeEntry];
                    else
                        %fprintf('Did not pass saccade amp threshold with: %f degrees\n',saccadeAmplitude)
                    end
                else
                    
                    if ~(peakIndex > previouSaccadeEndIndex)
                        %fprintf('Did not pass saccade index test\n')
                    else
                        %fprintf('Did not pass saccade vel threshold of: %f with vel %f\n',xVelThresh,absPeakXVel)
                    end
                    
                    
                end
            end
            
        else
            fprintf('WTF!! No saccades found in this trial!\n')
        end
        
        
        
    end
end

%% save output
% generate time stemp for saving
clock_temp = clock;
year_text = num2str(clock_temp(1));
year_text = year_text(end-1:end);
if clock_temp(2)>10
   month_text = num2str(clock_temp(2));
else
   month_text = ['0',num2str(clock_temp(2))];
end
if clock_temp(3)>10
   day_text = num2str(clock_temp(3));
else
  day_text = ['0',num2str(clock_temp(3))];
end
savefilename = [num2str(subj_id),'_anti_','EOG_Data'];

% save
save_dir=pwd;
disp(['Saving ' fullfile(save_dir,savefilename)]);
save(fullfile(save_dir,savefilename),'data','subj_id');

%% functions
    function [startIndex, endIndex] = GetContextWindow(srate, data, index ,seconds)
        
        windowSampleCount = floor(seconds * srate);
        dataSampleCount = size(data,1);
        
        startDiff = (index - ceil(windowSampleCount/2));
        endDiff = dataSampleCount - (index + ceil(windowSampleCount/2));
        
        if startDiff > 0 && ...
                endDiff > 0
            
            startIndex = index - ceil(windowSampleCount/2);
            endIndex = index + ceil(windowSampleCount/2);
            
        else
            
            if startDiff < 0 && ...
                    endDiff + startDiff >=0
                
                startIndex = (index - ceil(windowSampleCount/2) - startDiff + 1);
                endIndex = (index + ceil(windowSampleCount/2) - startDiff + 1);
                
            elseif endDiff < 0 && ...
                    startDiff + endDiff >=0
                
                startIndex = (index - ceil(windowSampleCount/2) + endDiff);
                endIndex = (index + ceil(windowSampleCount/2) + endDiff -1);
            else
                
                startIndex = 1;
                endIndex = windowSampleCount;
            end
            
        end
        
        if endIndex > dataSampleCount
            fprintf('bah!\n')
        end
        
    end


    function [dTheta] = CalculateAngularAmplitude(trialData, screenD)
        
        % Make a copy of the PlotParm gaze position data for modification
        positionData = trialData(:,1:2);
        startX = positionData(1,1);
        endX = positionData(end,1);
        
        dTheta = ( atan(endX/screenD) ...
            - atan(startX/screenD) );
        
    end


    function [vTheta] =  CalculateAngularVelocity(trialData, sampleInterval, screenD)
        
        positionData = trialData(:,1:2);

        % Initialize and empty vector to store the converted velocities.
        % Add an extra index to keep the velocity vector the same length as
        % the position vector after differentiation.
        vTheta = zeros((size(positionData,1)),1);
        
        for m=1:size(positionData,1)-1
            
            % X velocity
            vTheta(m+1,1) = ( atan(positionData(m+1,1)/screenD) ...
                - atan(positionData(m,1)/screenD) ) / sampleInterval;
            
        end
        
        % Duplicate the first velocity values for the first index
        vTheta(1,1) = vTheta(2,1);
        
    end

end



