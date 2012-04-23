function [ BehavStats ] = EOG_Scoring_wrapper( subj, right_saccade_sign, horizontal_EOG )
%This is a EOG scoring wrapper function specifically for the block anti/vgs
%project. This function will call on EOG_cal.m, MEG_EOG_to_cm.m,
%EOGExtractSaccades.m, ScoreMEGSaccades.m, and MEG_write_events.m to
%complete the full scoring pipeline. At the end it will write out event
%files in mne format, for anti and vgs conditions, and all trials. 
%
%   Usage [ BehavStats ] = EOG_Scoring_Wrapper( subj, right_saccade_sign )
%       Inputs :    subj - subject number
%
%                   right_saccade_sign - sign of EOG deflection for
%                   rightward saccade. Positive is 1, negative is -1. Note
%                   this is very important. Check the event "85" in
%                   mne_browse_raw, adn see if EOG is in the positive or
%                   negative. If you got this wrong trials will be scored
%                   wrong.
%                   
%                   horizontal_EOG - channel number for horizontal EOG, it
%                   is usually 308, but could be 307, check carefully!
%
%       Outputs:    Three classes of event files will be created:
%                   anti, vgs, and all.
%                   It will also separate correct vs incorrect trials. For
%                   details see MEG_write_events.m
%                   It will output the BehavStats to a matlab structure in
%                   the workspace.
%
%Last Update by Kai, 3.13.2012

if horizontal_EOG == 308
    vertical_EOG = 307;
elseif horizontal_EOG == 307
    vertical_EOG = 308;
end

%on arnold
[~,hostname] = system('hostname');
hostname = hostname(hostname ~= 10);
if strcmp('Schwarzenagger.local',hostname)
    MultiModal_DIR = '/Volumes/T800/Multimodal/ANTI/';
    WorkingDir = fullfile(MultiModal_DIR,num2str(subj),'/MEG');
else
    MultiModal_DIR = '/Volumes/T800/Multimodal/ANTI/';
    WorkingDir = fullfile(MultiModal_DIR,num2str(subj),'/MEG');
end
cd(WorkingDir);

% step 5.1, fit a voltage/cm line
EOG_cal(subj,horizontal_EOG,vertical_EOG,right_saccade_sign)

%step 5.2 convert trial by trial eog traces into cm.
% Note the prestem length have to be long enough to detect eye blinks during baseline
MEG_EOG_to_cm(subj,1:8,2.5,1)

% extract saccades
Data = strcat(num2str(subj),'_anti_EOG_Data.mat');
[~] = EOGExtractSaccades(subj,Data)

% score saccades
[~ ,BehavStats] = ScoreMEGSaccades(subj,Data,[25 35 65 75],[-1 1 1 -1]);

% write out trials to MNE event files, for anti condition, vgs, and all trials
Stim_anti = strcat(num2str(subj),'_anti');
Stim_vgs = strcat(num2str(subj),'_vgs');
Stim_all = strcat(num2str(subj),'_all');
[~, ~, ~] = MEG_write_events(Data,Stim_anti,[25,35],51,1)
[~, ~, ~] = MEG_write_events(Data,Stim_vgs,[65,75],51,1)
[~, ~, ~] = MEG_write_events(Data,Stim_all,[25,35,65,75],51,1)

% check for sensor artifacts
for run = 1:8
    fiff_file = strcat(num2str(subj),'_anti_run',num2str(run),'_dn_ds_sss_raw.fif');
    event_file = strcat(num2str(subj),'_anti-run',num2str(run),'-All.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_anti-run',num2str(run),'-Correct.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_anti-run',num2str(run),'-Incorrect.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_vgs-run',num2str(run),'-All.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_vgs-run',num2str(run),'-Correct.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_vgs-run',num2str(run),'-Incorrect.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_all-run',num2str(run),'-All.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_all-run',num2str(run),'-Correct.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
    event_file = strcat(num2str(subj),'_all-run',num2str(run),'-Incorrect.eve');
    [~]=MEG_reject_trial(fiff_file,event_file,2.5,0.5,1e-11,3e-10);
end
fclose('all');
end