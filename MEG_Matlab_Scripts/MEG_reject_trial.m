function [ bad_triallist ] = MEG_reject_trial( input, eventfile, prestim, poststim, MAGthresh, GRADthresh )
%This function will check for sensor artifacts for each trial, and reject
%trials that peak-to-peak amplitude that exceeds a preset threshold. The
%cleaned event list will be write out to a new file.
%
%Usage: [ bad_triallist ] = MEG_reject_trial( input, eventfile, prestim, 
%       poststim, MAGthresh, GRADthresh )
%
%   input - fiff file to be loaded
%   eventfile - event file in mne format that defines tials to be examined
%   prestim - prestimulus length in seconds
%   poststim - poststimulus length in seconds
%   MAGthresh - threshold for magnetometers, suggest values is 1e-11
%               if peak to peak value in any magnetometer channel exceeds
%               this threshold, trial will be removed from trial list.
%   Gradthresh - threshold for magnetometers, suggest values is 1e-11
%               if peak to peak value in any gradiometer channel exceeds
%               this threshold, trial will be removed from trial list.
%   bad_triallist = a list of bad trials
%
%   The cleaned events will be written to the same event file.
%
%Last update 3.15.2012 by Kai

%load data
%[output, events] = ft_load_fiff_sensors(input,eventfile, prestim, poststim);

% try using a different function, might be faster
prestim = prestim*1000;
poststim = poststim*1000;
[output, events] = MEG_load_sensor_trial(input,eventfile, prestim, poststim);
bad_triallist = [];

% check magnetometers
channel_list = ft_channelselection('M*1',output.label);
for i = 1:size(output.trial,2)
    for n = 1:size(channel_list,1)
        r = find(strcmp(output.label,channel_list(n)));
        maxi = max(output.trial{i}(r,:));
        mini = min(output.trial{i}(r,:));
        peaktopeak = maxi-mini;
        if peaktopeak > MAGthresh
            bad_triallist = [bad_triallist, i];
        end
    end
end

% check gradiometers
channel_list = ft_channelselection('M*2',output.label);
for i = 1:size(output.trial,2)
    for n = 1:size(channel_list,1)
        r = find(strcmp(output.label,channel_list(n)));
        maxi = max(output.trial{i}(r,:));
        mini = min(output.trial{i}(r,:));
        peaktopeak = maxi-mini;
        if peaktopeak > GRADthresh
            bad_triallist = [bad_triallist, i];
        end
    end
end
channel_list = ft_channelselection('M*3',output.label);
for i = 1:size(output.trial,2)
    for n = 1:size(channel_list,1)
        r = find(strcmp(output.label,channel_list(n)));
        maxi = max(output.trial{i}(r,:));
        mini = min(output.trial{i}(r,:));
        peaktopeak = maxi-mini;
        if peaktopeak > GRADthresh
            bad_triallist = [bad_triallist, i];
        end
    end
end

% write out cleaned trial list
if any(bad_triallist)
    bad_triallist = unique(bad_triallist);
    fprintf('\n*\n*\n*\n')
    disp(['Bad trials found:' num2str(length(bad_triallist)) ]);
    fprintf('\n*\n*\n*\n')
    bad_triallist = bad_triallist +1; %the first line in event file is all zero
    events(bad_triallist,:)=[];
    
    dlmwrite(eventfile, events, 'delimiter', '\t',  'precision', 10);
    
end
end

