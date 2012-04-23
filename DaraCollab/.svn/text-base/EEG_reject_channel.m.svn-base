function [ bad_channels ] = EEG_reject_channel( input, eventfile, outfile, prestim, poststim, EEGthresh, EEGvarthresh )
%This function will check for EEG sensor artifacts for each trial, and reject
%channels that have more than 5 trials where peak-to-peak amplitude exceeds 
%a preset threshold. Bad channel list will be written out.
%
%Usage: [ bad_channels ] = MEG_reject_trial( input, eventfile, prestim, 
%       poststim, EEGthresh )
%
%   input - fiff file to be loaded
%   eventfile - event file in mne format that defines tials to be examined
%   prestim - prestimulus length in ms
%   poststim - poststimulus length in ms
%   EEGthresh - threshold for EEG, suggest value is 150e-6
%   EEGvarthresh - threshold for EEG variance, suggest value is 5e-6. This
%   will find flat channels.s
%   bad_channels = a list of bad channels
%
%Last update 4.17.2012 by Kai

%load data
%[output, events] = ft_load_fiff_sensors(input,eventfile, prestim, poststim);

% try using a different function, might be faster
%prestim = prestim*1000;
%poststim = poststim*1000;
[output, events] = MEG_load_sensor_trial_old(input,eventfile, prestim, poststim);
[h]=fiff_setup_read_raw(input);
bad_triallist = [];
bad_channels = [];

% check EEG
channel_list = ft_channelselection('EEG',output.label);

for n = 1:size(channel_list,1)
    r = find(strcmp(output.label,channel_list(n)));
    bad_triallist = [];
    for i = 1:size(output.trial,2)
        maxi = max(output.trial{i}(r,:));
        mini = min(output.trial{i}(r,:));
        peaktopeak = maxi-mini;
        variance = std(output.trial{i}(r,:));
        if peaktopeak > EEGthresh 
            bad_triallist = [bad_triallist, i];
        end
        if variance < EEGvarthresh
            %variance;
            bad_triallist = [bad_triallist, i];
            %channel_list(n);
        end
    end
    bad_triallist = unique(bad_triallist);
    if length(bad_triallist)>20
    bad_channels = [bad_channels;channel_list(n)];
    end
end
bad_channels = unique([h.info.bads';bad_channels])

fid=fopen(outfile,'wt');

for b = 1:size(bad_channels,1)
    fprintf(fid, '%s\n',cell2mat(bad_channels(b)));
end
fclose(fid);
%dlmwrite(outfile, bad_channels, '')


end

