function  fixationList = ilabMkFixationList(data, idx)
% ILABMKFIXATIONLIST Calculates fixations
%    ILAB includes two types of fixation calculations: velocity and
%    dispersion based. In terms of the velocity algorithm, because eye
%    trackers typically acquire data at constant intervals the velocity
%    data is essentially equivalent to a distance measure. ILAB uses
%    distance because this is how the algorithm was originally set up.
%    The algorithm searches for point to point differences in vertical or
%    horizontal distance less than a chosen amount. Fixations also have
%    to meet a duration criteria. The velocity based method is very fast,
%    taking less than 1 second to calculate 100 fixations out of 12000
%    data points.
%
%    The dispersion algorithm is based on the article by Widdel, H. (1984).
%    Operational problems in analysing eye movements. In A. G. Gale & 
%    F. Johnson (Eds.), Theoretical and Applied Aspects of Eye Movement 
%    Research. North-Holland: Elsevier Science Publishers B.V.
%    In this case the algorithm initializes a window over the first n
%    points to cover the duration threshold. If the total dispersion (i.e.
%    for the combined horizontal + vertical directions ((max(H)-min(H)) + 
%    (max(V)-min(V))) is less or equal to the chosen threshold then points
%    are added to the fixation until the dispersion is greater than the
%    threshold. This algorithm also explicitly deals with missing data
%    points. In this case the user defines the maximum number of missing data
%    points to include in a fixation. A fixation is not terminated if the
%    duration of the missing data points is under this duration threshold.
%    If over the missing data duration threshold then the fixation is ended
%    before the missing data, and a new fixation search is started after the
%    missing data.
%
%    NOTE: This algorithm was modified in versions > 1.5 of
%    ilabMkFixationList. Previously the algorithm would move the fixation
%    window along the data stream and check if the dispersion was within
%    limits within the window only. It would then go back and examine over
%    all windows whether the dispersion came within limits. Unfortunately
%    this resulted in a loss of initial fixation points as the combined
%    window had to be collapsed to satisfy the dispersion limits. The
%    algorithm also computed x and y dispersions separately. However, this
%    could result in overall too much movement if both directions showed
%    movement just under the limits. The dispersion limits are now combined.
%
%    The dispersion based method is slower than the velocity method. It took  
%    13 seconds on the same 100 fixations out of 12000 data points.
%
%    Results of fixation analysis are stored in analysisParms.fix.list
%    Structure of analysisParms.fix.list array elements:
%    NOTE(!): Fixation Start and Fixation Duration are INDICES NOT TIMES.
%    Multiply by the Acquisition Interval to get the times.
%    fixationList = [trialnum xCtr yCtr xShiftDir dShift fixStartIndex fixDurationIndex pctInvalid];
% ___________________________________________________________________________

% Authors: Roger Ray, Darren Gitelman
% $Id: ilabMkFixationList.m 70 2010-06-07 00:23:51Z drg $


% Get some variables
% -----------------------------------------------------------------------------
AP = ilabGetAnalysisParms;
acqIntvl = ilabGetAcqIntvl;
nTrials = size(idx,1);
fixationList = [];
k = 1;

% Get calculation type based variables
switch AP.fix.type
    case 'vel'
        hMax = AP.fix.params.vel.hMax;
        vMax = AP.fix.params.vel.vMax;
        mindur = AP.fix.params.vel.minDuration/acqIntvl;
    case 'disp'
        MaxDisp = AP.fix.params.disp.Disp;
        % rounding upwards mindur ensures that a fixation lasts at least this
        % long and avoids problems with mindur not being an integer if the
        % minimum duration time is not evenly divisible by the acqIntvl.
        mindur = ceil(AP.fix.params.disp.minDuration/acqIntvl);
        nandur = AP.fix.params.disp.NaNDur;
end

ilabProgressBar('clear');
ilabProgressBar('setup');

for n = 1:nTrials
    %     ilabProgressBar('update',100*n/nTrials,...
    %         ['Calculating Fixations for Trial ' num2str(n)]);
    drawnow
    trial = data(idx(n,1):idx(n,2),1:2);
    
    switch AP.fix.type
        case 'vel'
            % Velocity or Distance based calculation	
            ilabProgressBar('update',100*n/nTrials,...
                ['Calculating Fixations for Trial ' num2str(n)]);
            
            % Calculate the percentage of invalid data points
            iNaN=find(~isfinite(trial(:,1)));
            pctInvalid=(length(iNaN)/length(trial))*100;
            
            % Find indices of valid pts in trial buffer
            trialIdx = find(isfinite(trial(:,1)));
            
            % calc movement
            trialdiff = [diff(trial(trialIdx,1)) diff(trial(trialIdx,2))];
            
            if isempty(trialdiff)
                fix1 = [];
                fix2 = [];
                fixList = [];
            else
                % ISCAN Varies in calculating fixations by using < and not <= as in ILAB
                % ILAB uses <= as this is what the user asks for
                trialfix = find((abs(trialdiff(:,1)) <= hMax) &...
                    (abs(trialdiff(:,2)) <= vMax));
                
                % Make a vector the same length as current trial
                fixList = zeros(size(trial,1),1);
                % put ones at the points where coord shifts lie in fixation rectangle
                fixList(trialfix) = ones(size(trialfix,1),1);
                % diff will tell us points of transition from 0 to 1.
                trialdiff2 = [0; diff(fixList)];
                
                fix1 = find(trialdiff2 ==  1);       %  0 -> 1
                fix2 = find(trialdiff2 == -1);       %  1 -> 0
            end	
            if isempty(fix1) && isempty(fix2) % either all movement or all fixation
                if ~isempty(fixList) && (fixList(1) == 1)
                    fix1 = 0;
                    fix2 = length(fixList);
                else
                    fix1 = 0;
                    fix2 = 0;
                end
            elseif isempty(fix2) % starts with movement, ends with fixation
                fix2 = length(fixList);
                % starts with fixation, ends with movement
            elseif	isempty(fix1)
                fix1 = [1; fix1];
            elseif fix2(1) < fix1(1)
                if length(fix1) == length(fix2)
                    fix1(1) = fix2(1);
                elseif 	length(fix1) < length(fix2)
                    fix1 = [1; fix1];	
                end	
            end
            
            fixDuration = (fix2 - fix1)*acqIntvl + acqIntvl;
            fixIdx = find(fixDuration >= mindur);   % indices of fix > minDuration
            
            trial = trial(trialIdx,1:2);
            
            %  Loop over all the fixations meeting min duration criterion
            %   and add an entry in the fixation list for each
            for j = 1:size(fixIdx,1)
                
                k = fixIdx(j);
                
                hpt = mean(trial(fix1(k):fix2(k),1));
                vpt = mean(trial(fix1(k):fix2(k),2));
                
                if j==1
                    lasthpt = hpt;
                    lastvpt = vpt;
                end			
                
                xShift = hpt - lasthpt;
                yShift = vpt - lastvpt;
                
                dShift = sqrt(abs((xShift)^2 + (yShift)^2));
                
                if xShift > 0
                    xShiftDir = 1;
                elseif xShift < 0
                    xShiftDir = -1;
                elseif xShift == 0
                    xShiftDir = 0;
                end
                
                lasthpt = hpt;
                lastvpt = vpt;
                
                fixDurIdx   = (fix2(k) - fix1(k)) + 1;
                fixStartIdx = fix1(k);
                
                fixationList = [fixationList; n hpt vpt xShiftDir dShift,...
                                fixStartIdx fixDurIdx pctInvalid];		
            end
        case 'disp'
            lasthpt = [];
            lastvpt = [];
            % locations of invalid data in entire trial
            trialnan = isnan(trial);
            pctInvalid=(length(find(trialnan(:,1)))/length(trial))*100;
            
            % i is the start counter for a fixation
            % j is the end counter.
            i = 1;
            while i < size(trial,1)-mindur
                % once i is closer to the end of the trial than the size
                % of the minimum duration window then we cannot define further fixations  
                ilabProgressBar('update',100*i/size(trial,1),...
                    ['Calculating Fixations at trial: ',num2str(n),...
                        ',  datapoint: ' num2str(i)]);
                drawnow
                nanend   = [];
                
                % check if index i falls on a NaN. This would occur with
                % missing data at the start of a trial or just after a
                % fixation. Advance past the missing data if this is the case.
                % This will avoid including NaN's in a fixation that has not
                % yet started.
                if any(trialnan(i,1:2))
                    nanidx = find(trialnan(i:end,1) == 0);
                    i = i + min(nanidx) -1;
                end
                
                % only enter the loop if finding a fixation is possible.
                if i <= size(trial,1) - mindur
                    j = i+mindur-1;
                    disph = max(trial(i:j,1)) - min(trial(i:j,1));
                    dispv = max(trial(i:j,2)) - min(trial(i:j,2));
                    disp = disph + dispv;
                    % j will be the counter to increment and defines the end of the fixation
                    while (disp <= MaxDisp)
                        ilabProgressBar('update',100*j/size(trial,1),...
                            ['Calculating Fixations at trial: ',num2str(n),...
                                ',  datapoint: ' num2str(j)]);
                        
                        if j < size(trial,1)
                            % increment j
                            j = j + 1;
                            nanend   = [];
                            
                            % if we've found NaNs then see if the duration of the
                            % NaNs exceeds the maximum NaN duration
                            % If it does then end the previous fixation before the NaN
                            if any(trialnan(j,1:2))
                                nanidx = find(trialnan(j+1:end,1) == 0);
                                % if nanidx is empty it means we've
                                % searched to the end of the trial and only
                                % found NaNs.
                                if isempty(nanidx)
                                    nanend = size(trial,1);
                                else
                                    nanend = j+min(nanidx)-1;
                                end
                                if (nanend-j+1) > nandur
                                    % j = j - 1; This is taken care of below
                                    % This backs up j by 1 so it is not in the
                                    % nan's. nanend also retains its value
                                    % so it will affect the value of i
                                    % below.
                                    break % leave while loop
                                else
                                    j = nanend + 1;
                                    % if nanend is at end of the trial then
                                    % subtract 1 from j.
                                    if j > size(trial,1)
                                        j = size(trial,1);
                                    end
                                    nanend = [];
                                end
                            end
                            
                            disph = max(trial(i:j,1)) - min(trial(i:j,1));
                            dispv = max(trial(i:j,2)) - min(trial(i:j,2));
                            disp = disph + dispv;
                        else
                            % This will be reduced by 1 on the line after the
                            % while loop.
                            if j == size(trial,1)
                                j = j + 1;
                            end
                            break % leave while (disp <= MaxDisp)
                        end % if j
                    end % while (disp <= MaxDisp)
                end % if i
                j = j - 1;
                
                % check if j - i exceeds the minimum fixation duration.
                if (j - i + 1 >= mindur)
                    % This calculation and check is a holdover from the
                    % previous version. I want to check if this ever fails
                    % and hope a user will alert me.
                    disph = max(trial(i:j,1)) - min(trial(i:j,1));
                    dispv = max(trial(i:j,2)) - min(trial(i:j,2));
                    disp = disph + dispv;
                    if disp > MaxDisp
                        error('Error in dispersion calculation, please inform the programmer.')
                    end
                    
                    % Find the data points that are not NANs for calculating the
                    % mean
                    innan = find(isfinite(trial(i:j,1)) | isfinite(trial(i:j,2)));
                    
                    meanh = mean(trial(i+innan-1,1));
                    meanv = mean(trial(i+innan-1,2));
                    
                    % calculate the direction of shift from the last fixation
                    % ---------------------------------------------------------
                    if isempty(lasthpt)
                        lasthpt = meanh;
                        lastvpt = meanv;
                    end			
                    xShift = meanh - lasthpt;
                    yShift = meanv - lastvpt;
                    dShift = sqrt(abs((xShift)^2 + (yShift)^2));
                    if xShift > 0
                        xShiftDir = 1;
                    elseif xShift < 0
                        xShiftDir = -1;
                    elseif xShift == 0
                        xShiftDir = 0;
                    end
                    lasthpt = meanh;
                    lastvpt = meanv;
                    
                    % assemble the fixation list
                    % ---------------------------------------------------------------
                    fixationList = [fixationList; n meanh meanv xShiftDir,...
                                    dShift i j-i+1 pctInvalid];
                    % in this case if nanend is not empty then start the next
                    % fixation at nanend else start next fixation after the
                    % current one.
                    if ~isempty(nanend)
                        i = nanend;
                    else
                        i = j+1;
                    end
                    
                else
                    % again if nanend isn't empty then start the next
                    % fixation after nanend else start fixation at i + 1
                    % since we never achieved a fixation at the last
                    % attempt.
                    if ~isempty(nanend)
                        i = nanend;
                    else
                        i = i + 1;
                    end
                end % if j - i + 1 >=mindur
                
            end % while
    end  % case
end % for n

ilabProgressBar('clear');

return;
