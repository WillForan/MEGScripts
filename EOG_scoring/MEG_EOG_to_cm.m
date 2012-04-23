function MEG_EOG_to_cm(subj_id, runs, pre_stim, post_stim)
% Looks up transformation information store in subid_eog_cal.mat and
% transform eog tracings of each run into cm.
%
% Usage: MEG_EOG_to_cm(subj_id, source_dir, runs, pre_stim, post_stim)
%
% Input:    subj_id - subject id,
%           source_dir - path to where experiment data are saved.
%           Experimental data wil have to be named
%           [subjid]_anti_runX_dn_ds_sss_raw.fif
%           runs - a vector indicating number of runs, e.g., [1:7]
%           pre_stim - prestimulus length in seconds
%           post_stim - post_stimulus length in seconds
%
% Written by Timothy Streeter
% Edited by Adrian KC Lee, Yigal Agam and Jesse Friedman from Manoach Lab
% Annotated and modified for the Luna lab by Kai Hwang
% last update 09.27.2011 

%% setup paths
deg_tx_dir=pwd;
save_dir=pwd;
source_dir=pwd;

%% Generate date text for saving
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
%savefilename = [num2str(subj_id),'_anti_',year_text,month_text,day_text,'_EOG_Data'];
savefilename = [num2str(subj_id),'_anti_','EOG_Data'];
%% load fit parameters
load(fullfile(deg_tx_dir,[num2str(subj_id) '_eog_cal.mat']));
horiz_eog = horizontal_eog;
vert_eog = vertical_eog;

%% loop across all runs, convert eog traces into cm
% if ~exist('runs')
%    runs=1:8;
% end
for run = runs
   disp(['Run ' num2str(run)]);
   data{run}.session_number=run;
   run_filename = fullfile(source_dir,[num2str(subj_id) '_anti_run' num2str(run) '_dn_ds_sss_raw.fif']);
   [raw,run_data] = read_fiff(run_filename);
   
   % save important info into output structure
   sr = raw.info.sfreq;     % sample rate
   data{run}.sr = sr;
   data{run}.initial_offset = raw.first_samp;
   data{run}.screen_distance = screen_distance;
   data{run}.pre_stim = pre_stim;
   data{run}.post_stim = post_stim;
   raw_triggers = run_data(310,:);    % triggers are in STI 101
   
   %% *** parse triggers ***
   % remove transitions to and from 0, for example: [0 2 10 10 10 10 0] should be a "10" trigger, so 2 should be removed
   for k = 3:length(raw_triggers) %triggers are somtmnes crazy at the begining
      % transition during trigger onset
      if raw_triggers(k)>0 && raw_triggers(k-1)>0 && raw_triggers(k-1)<raw_triggers(k) && raw_triggers(k-2)==0
         raw_triggers(k-1) = 0;
      end
      % transition during trigger offset
      if raw_triggers(k)==0 && raw_triggers(k-1)>0 && raw_triggers(k-1)<raw_triggers(k-2) && raw_triggers(k-2)>0
         raw_triggers(k-1) = 0;
      end
   end
   
   % pick only the first point in each trigger ([0 0 0 4 4 4 4 4 0 0 0 ==> a single "4" trigger)
   %triggers = find(raw_triggers==65 | raw_triggers==75 | raw_triggers==25 | raw_triggers==35); 
   % this will only find triggers of intest!!!!! MAKE SURE THESE ARE
   % TRIGGES YOU WANT!!!!
   %trig_diffs = diff(triggers);
   %trigger_times = triggers([1 find(trig_diffs>1)+1]);
   %trigger_values = raw_triggers(trigger_times); 
   if subj_id == 10613
        triggers = [find_trigger(1, raw_triggers), ...
            find_trigger(11, raw_triggers), ...
            find_trigger(25, raw_triggers), ...
            find_trigger(35, raw_triggers)];
       
   else
        triggers = [find_trigger(65, raw_triggers), ...
            find_trigger(75, raw_triggers), ...
            find_trigger(25, raw_triggers), ...
            find_trigger(35, raw_triggers)];
   end
   
   trigger_times = sort(triggers);
   trigger_values = raw_triggers(trigger_times);
   n_trigs = length(trigger_values);
   data{run}.trigger_times = trigger_times;
   data{run}.trigger_values = trigger_values;
   
   %% load eog data
   data{run}.raw_vertical_position = run_data(vert_eog,:);      % bipolar channel above and below left eye (in microvolts)
   data{run}.raw_vertical_position = filter_channel(data{run}.raw_vertical_position,sr,'notch',60)*1e6;
   data{run}.raw_vertical_mean = mean(data{run}.raw_vertical_position);
   data{run}.raw_vertical_std = std(data{run}.raw_vertical_position);
   data{run}.raw_horizontal_position = filter_channel(run_data(horiz_eog,:),sr,'high',0.1,'low',10)*1e6;
   horizontal_eog=filter_channel(run_data(horiz_eog,:),sr,'high',0.1,'low',10);    % horizontal EOG channel
   data{run}.horizontal_position = zeros(size(horizontal_eog));
   
   %% start loop through trials to convert EGO into cm
   % use fit parameters to convert the EOG trace to degrees.
   % for every trial, find the largest eog deflection, then scale it to degrees based on maximum deflection
   for trig = 1:n_trigs
      trig_time = trigger_times(trig);
      %start_time = trig_time-pre_stim*sr;
      cue_time = trig_time;
      end_time = trig_time+post_stim*sr;
      % set the horizontal position to 0 at the start of each trial
      % (by subtracting the first sample in each trial from the whole
      % trial)
      trial_horizontal = data{run}.raw_horizontal_position(cue_time:end_time);
      trial_horizontal = trial_horizontal-trial_horizontal(1);
      % now look for the biggest deflection from 0
      % and use that value to convert the whole trial to degrees
      
      max_eog = max(trial_horizontal);
      min_eog = min(trial_horizontal);
      if abs(max_eog)>abs(min_eog)
         biggest_eog=max_eog;
      else
         biggest_eog=min_eog;
      end
      
      % find degree: if y=a*x+b, then x=(y-b)/a
      biggest_degree = (biggest_eog-fit_params(2))/fit_params(1);
      data{run}.horizontal_position(cue_time:end_time) = trial_horizontal*biggest_degree/biggest_eog;
      
   end
   
   %data{run}.horizontal_mean=mean(data{run}.horizontal_position);
   %data{run}.horizontal_std=std(data{run}.horizontal_position);
end

%% save converted file
disp(['Saving ' fullfile(save_dir,savefilename)]);
save(fullfile(save_dir,savefilename),'data','subj_id');


