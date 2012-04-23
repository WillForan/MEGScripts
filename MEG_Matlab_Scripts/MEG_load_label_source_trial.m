function [ output ] = MEG_load_label_source_trial( inputfile, eventfile, preStim, postStim, paddingLength )
%This function will load trial by trial source estimates created by
%mne_compute_raw_inverse. Each data channel will be source estimates from
%one single label (ROI). This function will then read trial timing from the
%event file to chop epochs of interest, and compile a fieldtrip data
%structure.
%   
%   usage: [ output ] = MEG_load_label_source_trial( inputfile, eventfile,
%   pretStim, postStim, paddingLength )
%
%   Input:
%       inputfile - fiff file generated by mne_compute_raw_inverse
%       eventfile - event file listing trials of interest, in mne format
%       postStim - trial length, specify in ms 
%       preStim - length of presitm baseline, in ms
%       paddingLength - length of zero padding before and after the trial,
%       in ms.
%
%   Output:
%       output.label - cell-array containing strings, Nchan X 1
%       output.fsample - sampling frequency in Hz output.trial - cell-array
%           containing a data matrix for each trial (1 X Ntrial), each data
%           matrix is Nchan X Nsamples
%       output.time - cell-array containing a time axis for each trial (1 X
%           Ntrial), each time axis is a 1 X Nsamples vector. In Sec.
%       output.trialinfo - trigger code.
%
%   Last update April.4.2012, by Kai

%load fiff data
[hdr,data] = read_fiff(inputfile);
output = [];

%remove trigger line
data(end,:) = [];

%load event files
trigs = load(eventfile);

%check initial offset and sampling frequency
if trigs(1,1)~=hdr.first_samp
   fprintf('\n\t ******* ATTENTION!! initial offset betwen event and fiff file does not match. Wrong event file? Exiting ******* \n\n')
   return 
end

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
for n = 2:1:size(trigs,1)

    trialStart = trigs(n,1)-trigs(1,1) - (preStim/(1000/SamplingRate));
    trialEnd = trialStart + (epochLength/(1000/SamplingRate));
    padlength = paddingLength/(1000/SamplingRate);
    if trialStart <0
        fprintf('\n\t ******* ATTENTION!! event onset <0?? Wrong event file? Exiting ******* \n\n')
        return
    end

    
    %chop trial epochs
    Epoch = data(:,trialStart:trialEnd);
    ZeroPad = zeros(size(data,1),padlength);
    
    output.trial{n-1} = [ZeroPad,Epoch,ZeroPad];
    output.trialinfo(n-1,1) = trigs(n,4);
    output.time{n-1} = (-preStim-paddingLength)/1000:1/SamplingRate:(postStim+paddingLength)/1000; % in seconds
end

end

