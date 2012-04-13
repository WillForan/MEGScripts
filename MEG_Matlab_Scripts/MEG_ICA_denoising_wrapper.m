function MEG_ICA_denoising_wrapper( subjects, ekg_flag )
%This is a wrapper function that will run ICA denoising on multimodal anti
%subjects. The input files are assumed to be subj_anti_runx_ds_sss_raw.fif.
%Which has been downsampled and sss'd. The output will be
%subj_anti_runx_dn_ds_sss_raw.fif. The function will loop through subjects
%and runs in the multimodal anti study folder.
%   Usage: MEG_ICA_denoising_wrapper( subj )
%   subjects - vector of subjects to be analyzed
%   ekg_flag - flag to do aggresive ekg removal, lower r threshold to .1
%              1 = on, 0 = off.
%
%last update 3.14.2012.

for s = 1:size(subjects,2) 
    subj = subjects(s);
    
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
    
    for run =1:8
    Inputfile = fullfile(WorkingDir,strcat(num2str(subj),'_anti','_run',num2str(run),'_ds_sss_raw.fif'));
    Outputfile = fullfile(WorkingDir,strcat(num2str(subj),'_anti','_run',num2str(run),'_dn_ds_sss_raw.fif'));
    MEG_ICA_denoising(Inputfile,Outputfile, ekg_flag);
    end
end
end

