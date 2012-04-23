function [ PLV, timeVec, FOIs ] = MEG_PLV( Data, trials, source, target, FOIs, Fs, width)
% This function will calculate phase-locking value of MEG source
% timecourses from 2 ROIs. 
%   
%   Usage: [ PLV, timeVec, FOIs ] = MEG_PLV( Data, source, target, FOIs,
%   Fs, width)
%
%   Input:
%       Data - In filedtrip format. Will lookf for Data.trial
%            ROI by time by number of trial
%       trials - vector of trials to be included. 
%       source - the first ROI number
%       target - the second ROI number
%       FOIs - frequency of interst vector, i.e., 1:100
%       Fs - sampling frequency
%       width - number of cycles to be used for wavelet, usually 7
%
%   Output:
%       PLV = the time-frequency matrix of PLVs, freq x time.
%       timeVec - the time vector
%       FOIs - frequency of interest.
%
%
%   Last update Feb 21. 2012, by Kai

% reorganize Data.trial format in ROI by time by number of trial
tv = Data.time{1};
Data = cat(3,Data.trial{trials});
SourceData = squeeze(Data(source,:,:));
TargetData = squeeze(Data(target,:,:));
NumberOfTrials = size(SourceData,2);

freq_count=0;


PLV = zeros(size(FOIs,2),size(Data,2));
PhZ_tarseed = zeros(NumberOfTrials,size(Data,2));
NumberOfTrials

for FOI=FOIs
    freq_count=freq_count+1;
    
    for k = 1:NumberOfTrials
        
        seed_event=SourceData(:,k); %data time in column
        %added abs because prestim_points could be negative
        tar_event=TargetData(:,k);
        
        %clean powerline
        %seed_event=cca_multitaper(seed_event',Fs,60,50)';
        %tar_event=cca_multitaper(tar_event',Fs,60,50)';
        
        [TFR_seed,~,~]=traces2PLF(seed_event,FOI,Fs,width);
        [TFR_tar,timeVec,~]=traces2PLF(tar_event,FOI,Fs,width);
        PhZ_tarseed(k,:)=exp(1i*(angle(TFR_seed.*conj(TFR_tar))));
    end
    
    PLV(freq_count,:)=squeeze(abs(mean(PhZ_tarseed)));
end

timeVec = tv;


function [PLF,timeVec,freqVec] = traces2PLF(S,freqVec,Fs,width)
% function [PLF,timeVec,freqVec] = traces2PLF(S,freqVec,Fs,width);
%
% Calculates the phase locking factor for multiple trials using        
% multiple trials by applying the Morlet wavelet method.                            
%
% Input
% -----
% S    : signals = time x trials
% freqVec    : frequencies over which to calculate spectrogram 
% Fs   : sampling frequency
% width: number of cycles in wavelet (> 5 advisable)  
%
% Output
% ------
% timeVec    : time
% freqVec    : frequency
% PLF    : phase-locking factor = frequency x time
%
%
% Ole Jensen, August 1998
% 

S = S';
timeVec = (1:size(S,2))/Fs;  

B = zeros(length(freqVec),size(S,2)); %output structure, row is freqvec, column is time

for i=1:size(S,1)  % number of tirals        
%    fprintf(1,'%d ',i); 
    for j=1:length(freqVec)
        B(j,:) = phasevec(freqVec(j),detrend(S(i,:)),Fs,width) + B(j,:);  % phase vecotr function of time, add up across trials)
    end
end
% fprintf('\n'); 
B = B/size(S,1); % average phase factor across trials    


PLF = B;

function y = phasevec(f,s,Fs,width)
% function y = phasevec(f,s,Fs,width)
%
% Return a the phase as a function of time for frequency f. 
% The phase is calculated using Morlet's wavelets. 
%
% Fs: sampling frequency
% width : width of Morlet wavelet (>= 5 suggested).
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)


dt = 1/Fs;
sf = f/width;
st = 1/(2*pi*sf);

t=-3.5*st:dt:3.5*st;
m = morlet(f,t,width);

y = conv(s,m);

l = find(abs(y) == 0); 
y(l) = 1;

y = y./abs(y);
y(l) = 0;
   
y = y(ceil(length(m)/2):length(y)-floor(length(m)/2));



function y = morlet(f,t,width)
% function y = morlet(f,t,width)
% 
% Morlet's wavelet for frequency f and time t. 
% The wavelet will be normalized so the total energy is 1.
% width defines the ``width'' of the wavelet. 
% A value >= 5 is suggested.
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)
%
%
% Ole Jensen, August 1998 

sf = f/width;
st = 1/(2*pi*sf);
A = 1/sqrt(st*sqrt(pi));
y = A*exp(-t.^2/(2*st^2)).*exp(i*2*pi*f.*t);

