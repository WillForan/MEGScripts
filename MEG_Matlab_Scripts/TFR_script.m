% do TFR using morlet wavelet on mix data. 
% 10.21.2011

%% setup config
for n=1:size(RLDATA,2)
    %only analyze correct trials
    cfg{n} = [];
    %cfg{n}.trials=find(DATA{n}.data.trialinfo==1)';
    cfg{n}.method     = 'wavelet';
    cfg{n}.width      = 7;
    cfg{n}.output     = 'fourier';
    cfg{n}.foi        = 4:2:60;
    cfg{n}.toi        = -2.3:0.02:0.2;
    cfg{n}.keeptrials = 'yes';
    cfg{n}.keeptapers = 'yes';
    cfg{n}.channel = 'all';
    cfg{n}.channelcmb = 'all';
    cfg{n}.pad =5;
    
end


for n=1:size(RLDATA,2)
    %analyze all trials
    RLTFR_f{n} = ft_freqanalysis(cfg{n}, RLDATA{n}.data);
end


for n=1:size(DATA,2)
    %only analyze correct trials
    cfg{n} = [];
    %cfg{n}.trials=find(DATA{n}.data.trialinfo==1)';
    cfg{n}.method     = 'wavelet';
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


for n=1:size(DATA,2)
    %analyze all trials
    TFR_f{n} = ft_freqanalysis(cfg{n}, DATA{n}.data);
end


save TFR_fourier_DATA.mat -v7.3