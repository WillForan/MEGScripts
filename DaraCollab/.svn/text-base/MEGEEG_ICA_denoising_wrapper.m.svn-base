function MEGEEG_ICA_denoising_wrapper( subjects, ekg_flag )
%This is a wrapper function that will run ICA denoising on MEGH's prep
%data.
%subjects. The input files are assumed to be subj_0x_ssss.fif.
%Which has been downsampled and sss'd. The output will be
%subj_prep_runx_dn_sss_raw.fif. The function will loop through subjects
%and runs in the multimodal anti study folder.
%   Usage: MEGEEG_ICA_denoising_wrapper( subj, ekg_flag )
%   subjects - vector of subjects to be analyzed
%   ekg_flag - flag to do aggresive ekg removal, lower r threshold to .1
%              1 = on, 0 = off.
%
%last update 3.14.2012.

for s = 1:size(subjects,1) 
    subj = subjects(s,:);
    
    %on arnold
    [~,hostname] = system('hostname');
    hostname = hostname(hostname ~= 10);
    if strcmp('Schwarzenagger.local',hostname)
        Study_DIR = '/Volumes/T800/Multimodal/ANTI/';
        WorkingDir = fullfile(Study_DIR,num2str(subj),'/MEG');
    elseif strcmp('wallace.wpic.upmc.edu',hostname)
        Study_DIR = '/raid/r3/p2/Luna/dataFromDisks/MEG/subjects';
        WorkingDir = fullfile(Study_DIR,subj,'/SSS');
    end
    
    for run =1:8
    Inputfile = fullfile(WorkingDir,strcat(subj,'_0',num2str(run),'_sss.fif'));
    Outputfile = fullfile(WorkingDir,strcat(subj,'_prep_run',num2str(run),'_dn_sss_raw.fif'));
    MEGEEG_ICA_denoising(Inputfile,Outputfile, ekg_flag);
    end
end
end

