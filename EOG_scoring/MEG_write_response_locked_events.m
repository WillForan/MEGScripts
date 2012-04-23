function [ CorrectTrials InCorrectTrials AllTrials ] = MEG_write_response_locked_events( InputData, stim, trig, delay, write_flag )
% This function will take outputs from ScoreMEGSaccades.m and create event
% files for MNE pipeline. The onset of each event will be shift to the onset
% of saccades. This function will loop through runs in the mat
% file and create event files separately for each run.
%
%   Usage:  [CorrectTrials InCorrectTrials AllTrials] = MEG_write_events(
%   InputData, stim, trig, delay)
%
%   Inputs: InputData - output .mat file from ScoreMEGSaccades.m
%           stim - the prefix of event file output, for example
%           subjn_Mix_ANTI_Left. The program will then append run number
%           and .eve after it.
%
%           trig - vector of triggers you want to create event files for.
%           The function will create three event files: correct, incorrect
%           and all trials where correct trials will be indexed by a trig
%           code 1, and inccorect trials 2. Note the function will take
%           more then one triggers if you wish to combine different trial
%           types. However in the event file all trigs will be replaced by
%           the first element in the trig vector.
%
%           delay - the trigger-to-stimulus onset delay, in ms. This part
%           is important for accounting for accurate timing.
%
%           write_flag - a flag indicating whether or not to write out
%           event files, 1 will write out events, 0 will keep outputs in
%           workspace.
%           
%
%   Outputs: Will create .eve files for each run. As will as strctures
%   containing correct, incorrect, and all trials. It is possible to use
%   these output structures for Fieldtrip.
%
%   Written by Kai Hwang, last update 10.14.2011

load(InputData);

runs = 1:1:size(data,2);
for run = runs
    disp(['********* PROCESSING Run ' num2str(run)]);
    
    % first vecotr (initial offset)
    evetFirstVector = [double(data{run}.initial_offset), double(data{run}.initial_offset)*double(1/data{run}.sr), 0, 0];
    
    % Table for correct trials
    CeventVector=[];
    for t=1:1:size(data{run}.Scored_saccadeTable,1)
        if any(data{run}.Scored_saccadeTable(t,3) == trig) && data{run}.Scored_saccadeTable(t,8) == 1
            CeventVector = [CeventVector; ...
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2) ...
                + round(delay/(1000/data{run}.sr)) ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))),    ... %saccade reaction time is in ms
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2)    ...
                + round(delay/(1000/data{run}.sr)) ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))) * double(1/data{run}.sr),   ...
                0, trig(1)];
        end 
    end
    
    % Table for Incorrect trials
    IneventVector=[];
    for t=1:1:size(data{run}.Scored_saccadeTable,1)
        if any(data{run}.Scored_saccadeTable(t,3) == trig) && data{run}.Scored_saccadeTable(t,8) == 0
            IneventVector = [IneventVector; ...
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2) ...
                + round(delay/(1000/data{run}.sr)) ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))),    ...
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2)    ...
                + round(delay/(1000/data{run}.sr)) ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))) * double(1/data{run}.sr),   ... 
                0, trig(1)];
        end 
    end
    
    % Table for all trials
    eventVector=[];
    for t=1:1:size(data{run}.Scored_saccadeTable,1)
        if any(data{run}.Scored_saccadeTable(t,3) == trig) && data{run}.Scored_saccadeTable(t,8) == 1
            eventVector = [eventVector; ...
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2) ...
                + round(delay/(1000/data{run}.sr))  ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))),    ...
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2)    ...
                + round(delay/(1000/data{run}.sr))  ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))) * double(1/data{run}.sr),   ...
                0, 1];
        elseif any(data{run}.Scored_saccadeTable(t,3) == trig) && data{run}.Scored_saccadeTable(t,8) == 0
            eventVector = [eventVector; ...
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2) ...
                + round(delay/(1000/data{run}.sr))  ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))),    ...
                double(data{run}.initial_offset + data{run}.Scored_saccadeTable(t,2)    ...
                + round(delay/(1000/data{run}.sr))  ...
                + round(data{run}.Scored_saccadeTable(t,4)/(1/data{run}.sr))) * double(1/data{run}.sr),   ...
                0, 2];
        end 
    end
    
    CorrectTrials{run} = [evetFirstVector;CeventVector];
    InCorrectTrials{run} = [evetFirstVector;IneventVector];
    AllTrials{run} = [evetFirstVector;eventVector];
    
    if write_flag == 1
        fname=strcat(stim,'-RL-run',num2str(run),'-All.eve');
        dlmwrite(fname, AllTrials{run}, 'delimiter', '\t',  'precision', 10);
        
        fname=strcat(stim,'-RL-run',num2str(run),'-Correct.eve');
        dlmwrite(fname, CorrectTrials{run}, 'delimiter', '\t',  'precision', 10);
        
        fname=strcat(stim,'-RL-run',num2str(run),'-Incorrect.eve');
        dlmwrite(fname, InCorrectTrials{run}, 'delimiter', '\t',  'precision', 10);
    end
end



end

