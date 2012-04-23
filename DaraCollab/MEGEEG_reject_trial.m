function [ bad_triallist ] = MEGEEG_reject_trial( input, eventfile, outfile, prestim, poststim, MAGthresh, GRADthresh, EEGthresh, EEGvarthresh )
%This function will check for sensor artifacts for each trial, and reject
%trials that peak-to-peak amplitude that exceeds a preset threshold. The
%cleaned event list will be write out to a new file. This function will
%check for MEG plus EEG channels.
%
%Usage: [ bad_triallist ] = MEG_reject_trial( input, eventfile, prestim, 
%       poststim, MAGthresh, GRADthresh )
%
%   input - fiff file to be loaded
%   eventfile - event file in mne format that defines tials to be examined
%   outfile - output file name
%   prestim - prestimulus length in seconds
%   poststim - poststimulus length in seconds
%   MAGthresh - threshold for magnetometers, suggest values is 1e-11
%               if peak to peak value in any magnetometer channel exceeds
%               this threshold, trial will be removed from trial list.
%   Gradthresh - threshold for magnetometers, suggest values is 3e-10
%               if peak to peak value in any gradiometer channel exceeds
%               this threshold, trial will be removed from trial list.
%
%   EEGthresh - threshold for EEG, suggest value is 150e-6
%   EEGvarthresh - threshold for EEG signal variance, suggest value is 5e-6
%                   This is to detect flat EEG channels.
%   bad_triallist = a list of bad trials
%
%   The cleaned events will be written to the same event file.
%
%Last update 4.22.2012 by Kai


prestim = prestim*1000;
poststim = poststim*1000;
events = load(eventfile);
if events(1,1)~=0
    [output, events] = MEG_load_sensor_trial(input,eventfile, prestim, poststim);
elseif events(1,1)==0
    [output, events] = MEG_load_sensor_trial_old(input,eventfile, prestim, poststim);
end
bad_triallist = [];
bad_channels = [];
for e=1:size(output.hdr.info.bads,2)
    bad_channels = [bad_channels, find(strcmp(output.hdr.info.ch_names,output.hdr.info.bads(e)))];
end

% check magnetometers
channel_list = ft_channelselection('M*1',output.label);
for i = 1:size(output.trial,2)
    for n = 1:size(channel_list,1)
        r = find(strcmp(output.label,channel_list(n)));
        if any(r==bad_channels)
           continue 
        end
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
        if any(r==bad_channels)
           continue 
        end
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
        if any(r==bad_channels)
           continue 
        end
        maxi = max(output.trial{i}(r,:));
        mini = min(output.trial{i}(r,:));
        peaktopeak = maxi-mini;
        if peaktopeak > GRADthresh
            bad_triallist = [bad_triallist, i];
        end
    end
end
% %check EEG
channel_list = ft_channelselection('EEG*',output.label);
for i = 1:size(output.trial,2)
    for n = 1:size(channel_list,1)
        r = find(strcmp(output.label,channel_list(n)));
        if any(r==bad_channels)
           continue 
        end
        maxi = max(output.trial{i}(r,:));
        mini = min(output.trial{i}(r,:));
        peaktopeak = maxi-mini;
        variance = std(output.trial{i}(r,:));
        if peaktopeak > EEGthresh 
            bad_triallist = [bad_triallist, i];
        end
        if variance < EEGvarthresh
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
    if events(1,1)==0
        events=[0 0 0 0;events];
        bad_triallist = bad_triallist+1;
        events(bad_triallist,:)=[];
    else
        events(bad_triallist,:)=[];
    end
    
    if size(events,1)<5
       warningfile=strcat(outfile,'WARNING')
        dlmwrite (warningfile,events,'delimiter', '\t',  'precision', 10);
    end
    
    dlmwrite(outfile, events, 'delimiter', '\t',  'precision', 10);
    
else
    events=[0 0 0 0;events];
    dlmwrite(outfile, events, 'delimiter', '\t',  'precision', 10);
end


end

