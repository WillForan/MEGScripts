% do TFR using morlet wavelet convolve on mix data. 
% 11.28.2011

%% setup config

%for n=1:size(DATA,2)
for n =1
    %only analyze correct trials
    cfg{n} = [];
    %cfg{n}.trials=find(DATA{n}.data.trialinfo==1)';
    cfg{n}.method     = 'tfrhelp';
    cfg{n}.width      = 7;
    cfg{n}.output     = 'fourier';
    cfg{n}.foi        = 4:2:60;
    cfg{n}.toi        = -2.0:0.02:0.5;
    cfg{n}.keeptrials = 'yes';
    cfg{n}.keeptapers = 'yes';
    cfg{n}.channel = 'all';
    cfg{n}.channelcmb = 'all';
    cfg{n}.pad =5;
    
end

for n =1
%for n=1:size(DATA,2)
    %analyze all trials
    TFR_f{n} = ft_freqanalysis(cfg{n}, DATA{n}.data);
end


%save TFRwav_fourier_DATA.mat -v7.3