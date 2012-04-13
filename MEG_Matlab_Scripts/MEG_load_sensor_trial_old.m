function [ output, events ] = MEG_load_sensor_trial_old( inputfile, eventfile, preStim, postStim )
%This function will load trial by trial sensor data. 
%This function will then read trial timing from the
%event file to chop epochs of interest, and compile a fieldtrip data
%structure. Not the event file has to be the "old" format. 
%   
%   usage: [ output, events ] = MEG_load_sensor_trial( inputfile, eventfile,
%   pretStim, postStim )
%
%   Input:
%       inputfile - fiff file
%       eventfile - event file listing trials of interest, in mne format
%       postStim - trial length, specify in ms 
%       preStim - length of presitm baseline, in ms
%
%   Output:
%       output.label - cell-array containing strings, Nchan X 1
%       output.fsample - sampling frequency in Hz output.trial - cell-array
%           containing a data matrix for each trial (1 X Ntrial), each data
%           matrix is Nchan X Nsamples
%       output.time - cell-array containing a time axis for each trial (1 X
%           Ntrial), each time axis is a 1 X Nsamples vector. In Sec.
%       output.trialinfo - trigger code.
%       events - events in mne event file format
%
%   Last update 3.15.2012, by Kai

%load fiff data
[hdr,data] = read_fiff(inputfile);
output = [];

%remove trigger line
data(end,:) = [];

%load event files
trigs = load(eventfile);
events = trigs;

%check initial offset and sampling frequency
%if trigs(1,1)~=hdr.first_samp
%   fprintf('\n\t ******* ATTENTION!! initial offset betwen event and fiff file does not match. Wrong event file? Exiting ******* \n\n')
%   return 
%end

SamplingRate = hdr.info.sfreq;
% if hdr.info.sfreq~=SamplingRate
%    fprintf('\n\t ******* ATTENTION!! Samplingrate mismatch. Wrong event file? Exiting ******* \n\n')
%    return
% end

%label names
output.label = hdr.info.ch_names(1:end-1)';

%sampling frequency
output.fsample = hdr.info.sfreq;
epochLength = preStim+postStim;

output.trial = [];
for n = 1:1:size(trigs,1)

    trialStart = round(trigs(n,1) - (preStim/(1000/SamplingRate)));
    trialEnd = trialStart + round(epochLength/(1000/SamplingRate));
    
    if trialStart <0
        fprintf('\n\t ******* ATTENTION!! event onset <0?? Wrong event file? Exiting ******* \n\n')
        return
    end

    
    %chop trial epochs
    Epoch = data(:,trialStart:trialEnd);
    
    output.trial{n} = Epoch;
    output.trialinfo(n,1) = trigs(n,4);
    output.time{n} = -preStim/1000:1/SamplingRate:postStim/1000; % in seconds
end
output.hdr = hdr;
fclose('all');
end

