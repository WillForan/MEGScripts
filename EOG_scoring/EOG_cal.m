function EOG_cal(subj_id, horizontal_eog, vertical_eog, right_saccade_sign)
% Using the calibration run (in MEG) to calibrate
% EOG reading into visual degrees.
%
% Usage: EOG_cal(subj_id, source_dir, horizontal_eog, vertical_eog, right_saccade_sign)
%
% Input:
%       subj_id - subjet id, will search for subjid_Calibration_ds_raw.ff
%       horizontal_eog - channel number for horizontal eog, should be 308
%       vertical_eog - channel number for vertical eog, should be 307
%       right_saccade_sign - sign of EOG delfection for rightward saccade
%
% Output will be saved inot [subjid]_eog_cal.mat.
% Outputs include fit parameters (calibration) which can later be used to
% convert eog tracings from experimental sessions into visual degree
%
% Authors: Adrian KC Lee, Yigal Agam from the Manoach lab
% Modififed and annoatated by Kai Hwang for the Luna lab.
% Last update 09.28.2011



%% setup paths

current_dir = pwd;
source_dir = pwd;
addpath(current_dir);
save_file = [num2str(subj_id) '_eog_cal'];

%% load data from calibration session

% read calibration file
raw = fiff_setup_read_raw(fullfile(source_dir,[num2str(subj_id) '_calib_ds_raw.fif']));
cal_data = fiff_read_raw_segment(raw);

sr = raw.info.sfreq;     % sampling rate
raw_triggers = cal_data(310,:);    % trigger channel STI 101 is channel 310
horizontal = filter_channel(cal_data(horizontal_eog,:),sr,'high',1,'low',20)*1e6;  % input horizontal EOG channel
vertical = cal_data(vertical_eog,:);  % vertical EOG channel
vertical = zscore(vertical);
zhorizontal = zscore(horizontal);
time_after_trig = 0.6;     % time to consider after triggers for saccade calculation
time_before_trig = 0.3;     % time to consider before triggers for saccade calculation


%% process triggers

%triggers = find(raw_triggers > 1);
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

%triggers = find(raw_triggers == 65 | raw_triggers == 75)
%trig_diffs = diff(triggers);
%trigger_times = triggers([1 find(trig_diffs>1) +1])
%trigger_values = raw_triggers(trigger_times)


triggers = [find_trigger(15, raw_triggers),find_trigger(25, raw_triggers) ...
    find_trigger(35, raw_triggers),find_trigger(45, raw_triggers) ...
    find_trigger(55, raw_triggers),find_trigger(65, raw_triggers) ...
    find_trigger(75, raw_triggers),find_trigger(85, raw_triggers)];

trigger_times = sort(triggers);
trigger_values = raw_triggers(trigger_times);
sequence_values={[],[],[],[]};
%sequence_labels={'right 11','left 11 ','right 11','left 11',...
%                 'right 11','left 11','right 11','left 11'};
sequence_labels={'-210','-160','-110','-60','60','110','160','210'};

%% plot the four sequence repetitions, each in a different subplot
eog_figure=figure;
set(gcf,'numbertitle','off','name',[num2str(subj_id) ' EOG Calibration']);
for sq=1:4 % plot through calibration sequence
    
    %% first, extract EOG trace from each sequence
    sequence{sq} = horizontal(trigger_times(8*(sq-1)+1)-100:trigger_times(8*sq)+round(time_after_trig*sr));
    % extract trigger time stamps for current sequence
    sequence_trig_times = (trigger_times(8*(sq-1)+1:8*sq)-trigger_times(8*(sq-1)+1))/sr;
    % extract trigger values (indicating saccade size and direction) for current sequence
    sequence_trig_values = trigger_values(8*(sq-1)+1:8*sq);
    
    %% ploting
    subplot(2,2,sq);
    title(['Sequence ' num2str(sq)],'fontsize',16);
    xlabel('Time (sec)');
    ylabel('Horizonal EOG (Microvolt)')
    hold on
    % plot whole sequence horizontal EOG
    plot(0:1/sr:(length(sequence{sq})-1)/sr,sequence{sq},'color','black');
    set(gca,'xlim',[0 length(sequence{sq})/sr],'ylim',get(gca,'ylim')*1.1);
    
    
    %% find max deflection
    for tr=1:8 % each sequnce will have two trials, first left then right. NOTE THIS WILL CHANGE DEPENDS ON THE PARADIGM!!!!
        % plot vertical dashed lines for individual triggers
        line([sequence_trig_times(tr)+0.05 sequence_trig_times(tr)+0.05], ...
            get(gca,'ylim'),'linewidth',0.25,'color','black','linestyle','--');
        
        % for every saccade, find the range of the signal between [time_before_trig] before saccade stimulus
        % and [time_after_trig] after saccade stimulus
        trig_time=trigger_times(2*(sq-1)+tr);
        sequence_tr{tr} = horizontal((trig_time-time_before_trig*sr):(trig_time+time_after_trig*sr));
        sequence_vertical_tr{tr} = vertical((trig_time-time_before_trig*sr):(trig_time+time_after_trig*sr));
        sequence_z_tr{tr} = zhorizontal((trig_time-time_before_trig*sr):(trig_time+time_after_trig*sr));
        initial_voltage = sequence_tr{tr}(1);
        sequence_tr{tr} = sequence_tr{tr}-sequence_tr{tr}(1);
        
        %-initial_voltage; % convert to relative to initial voltage
        [min_point,i_min] = min(sequence_tr{tr});
        [max_point,i_max] = max(sequence_tr{tr});
        
        %find eye blinks
        [Vmin_point,Vi_min] = min(sequence_vertical_tr{tr});
        [Vmax_point,Vi_max] = max(sequence_vertical_tr{tr});
        [Zmin_point,Vi_min] = min(sequence_z_tr{tr});
        [Zmax_point,Vi_max] = max(sequence_z_tr{tr});
        
        if Vmax_point > 3.0
            max_point = nan;
            min_point = nan;
        elseif Vmin_point < -3.0
            max_point = nan;
            min_point = nan;
        elseif Zmax_point > 3
            max_point = nan;
            min_point = nan;
        elseif Zmin_point < -3
            max_point = nan;
            min_point = nan;
        end
        
        % store max or min signal change in a cell array
        %sequence_values{sq}=[sequence_values{sq} (max_point-min_point)*(2*(i_min<i_max)-1)];
            
        if sequence_trig_values(tr) == 15 && right_saccade_sign < 0 
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        elseif sequence_trig_values(tr) == 15 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 25 && right_saccade_sign < 0
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        elseif sequence_trig_values(tr) == 25 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 35 && right_saccade_sign < 0
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        elseif sequence_trig_values(tr) == 35 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 45 && right_saccade_sign < 0
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        elseif sequence_trig_values(tr) == 45 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 55 && right_saccade_sign < 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 55 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        elseif sequence_trig_values(tr) == 65 && right_saccade_sign < 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 65 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        elseif sequence_trig_values(tr) == 75 && right_saccade_sign < 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 75 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        elseif sequence_trig_values(tr) == 85 && right_saccade_sign < 0
            sequence_values{sq} = [sequence_values{sq} max_point];
            
        elseif sequence_trig_values(tr) == 85 && right_saccade_sign > 0
            sequence_values{sq} = [sequence_values{sq} min_point];
            
        end
        
    end
end

%% show the automatically extracted values, plus a linear fit to the averages
EOG_cal_cm_plot_saccades_and_fit;  %can use cal_cm if want to convert to cm instead of degrees
set(gcf,'name',[num2str(subj_id) ' calibration curve']);
figure(eog_figure);
drawnow;

%save screen distance into output, will later be used to calculate
%visualdegree
screen_distance=106.18;

%% save calibration params
disp(['Saving to ' fullfile(current_dir,save_file)]);
% save fit parameters
save(fullfile(current_dir,[save_file '.mat']),'fit_params','mean_saccade','std_saccade','median_saccade','saccade_values', 'horizontal_eog', 'vertical_eog', 'right_saccade_sign', 'screen_distance');
% save fit figure
saveas(fit_fig,fullfile(current_dir,[save_file '.fig']),'fig');