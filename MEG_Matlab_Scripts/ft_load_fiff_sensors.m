function [ output, events ] = ft_load_fiff_sensors( input_file, event_file, prestim, poststim )
%This function will load a fiff file, a event file, and create the
%appropriate fieldtrip data structure for subsequent fieldtrip analyses.
%Sampling frequency will be read from the fiff file header. Prestim and
%poststim time intervals should be in seconds. This function will not do
%complex definition of trials, and will process all trials as specified in
%the event file. Therefore you should make custom event files if you only
%want to look at certain trials (base on condition, performance... etc).
%
%   Fieldtrip matlab toolbox must be in your matlab path.
%   
%   Usage: [ output, events ] = ft_load_fiff_trials( input_file, event_file,
%   prestim, poststim )
%
%   Input:
%       input_file - fiff file
%       event_file - event file in mne format
%       prestim - prestimulus baseline, in seconds
%       poststim - length of trial after trigger, in seconds
%
%   Output is data strcutre in fieldtrip format
%   events is the mne event file
%
%
%   Note this function will also work with source estimates. Source
%   estimates must be in fiff format computer with mne_compute_raw_inverse
%   with the label options. In that case each cahnnel will be source
%   estiamtes from one label (or ROI).
%
%   Last update Nov 30 2011, by Kai

%determine sampling frequency
hdr = ft_read_header(input_file);
%  hdr.Fs will be the sampling frequency

cfg.dataset = input_file;

%process event file
trials = load(event_file);
trialVec=trials(:,1)-trials(1,1);
trialVec=trialVec(2:end);

% create trial structure for fieldtrip
eventVec=[trialVec-(prestim/(1/hdr.Fs)), trialVec+(poststim/(1/hdr.Fs))];
eventVec(:,3)=(-1*(prestim/(1/hdr.Fs)));

removeVec=[];
for i=1:size(eventVec,1)
    if eventVec(i,1) < 0
        removeVec=[removeVec,i];
    end
end
eventVec(removeVec,:)=[];
cfg.trl=eventVec;

% create data strcuture for fieldtrip
output=ft_preprocessing(cfg);
events = trials;
end

