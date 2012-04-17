function [ bad_triallist ] = MEG_reject_trial( input, eventfile,newEventfile, prestim, poststim, MAGthresh, GRADthresh, MOTthres )
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
% update 3.15.2012 by Kai
% update 4.17.2012 (WF)

%load data
%[output, events] = ft_load_fiff_sensors(input,eventfile, prestim, poststim);

% try using a different function, might be faster
 prestim =  prestim*1000;
poststim = poststim*1000;

% load output struct for each event/trial + displacement channel"
[output, events] = MEG_load_sensor_trial(input,eventfile, prestim, poststim);
bad_triallist = [];

Thresholds = {  ...
 % cRegexp        cThres
 {'displacement', MOTthres  }  % motion
 {'M*1',          MAGthres  }  % magnetometers
 {'M*2',          GRADthres }  % grad
 {'M*3',          GRADthres }
};

%% check every channel matching each regexp for each threshold type

for t = 1:length(Thresholds)
   cRegexp = Thres{t}{1};
   cThres  = Thres{t}{2};

   % get the name of every channel matching the regexp
   channel_list = ft_channelselection(cRegexp,output.label);

   % go through each trial
   for i = 1:size(output.trial,2)
       % and each regexp match
       for n = 1:size(channel_list,1)

           % find the channel number matching this specific match of the regexp
           r = find(strcmp(output.label,channel_list(n)));

           % get the maximum difference
           maxi = max(output.trial{i}(r,:));
           mini = min(output.trial{i}(r,:));
           peaktopeak = maxi-mini;

           % drop if too high
           if peaktopeak > cThres 
               bad_triallist = [bad_triallist, i];
               fprintf('Dumping %i because %.4f > %.4f (%s)\n', i,maxi,cThres,cRegexp);
           end
       end % channels
   end % trial
end % thresholds

%% write out cleaned trial list
if any(bad_triallist)
    bad_triallist = unique(bad_triallist);
    fprintf('\n*\n*\n*\n')
    disp(['Bad trials found:' num2str(length(bad_triallist)) ]);
    fprintf('\n*\n*\n*\n')
    bad_triallist = bad_triallist +1; %the first line in event file is all zero
    events(bad_triallist,:)=[];
    
    dlmwrite(newEventfile, events, 'delimiter', '\t',  'precision', 10);
    
end 

end % of function

