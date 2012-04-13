function [ Output ] = Load_MNEsources_to_ft_wrapper_RT(subs, runs, source, source_cond, event_cond, event_type, sr, prestim, poststim, RLflag)
%This is a wrapper function that calls MEG_load_label_source_trial to load
%multiple runs of data from multiple subjects into a FT structure. This
%version will load RT data.
%
%   Inputs:
%       subs - a vector of subject ids
%       runs - a vectir indicating runs, i.e., [1:7]
%       source - path to subjects' data, i.e.,g MEG/Mix. Then under this
%           folder will be each subject's folder. Note there must be an
%           "Events" folder in each subject's folder.
%       source_cond - source file's prefix. Source files are usually like
%           [subjid]-ANTI-runX-label-source_raw.fif. "ANTI" will be
%           source_cond.
%       event_cond - event file's prefix. Event files are usually named
%           as [subid]-Mix-ANTI-runX-All.eve. "Mix-ANTI" will be
%           event_cond.
%       event_type - TYpes of events, "Correct", "Incorrect", or "All".
%       sr - sampling rate of the events file. MUST MATCH The source fiff
%           files.
%       prestim - length of pre stimulus epoch you want to analyze. in ms.
%       poststim - length of post stimulus epoch you wish to analyze, in
%           ms.
%       RLflag - whether or not the event files are locked to response
%       onset. 1 = yes, 0 = no.
%       
%   Outputs will be a structure containing sub-structures of each subject.
%   Each subject's structure will be in ft format.
%
%   Last update 10.15.2011, by Kai Hwang   


Output={};
for sub = 1:size(subs,2)
    Output{sub}.Subject =subs(sub);
    source_dir = fullfile(source,num2str(subs(sub)));
    event_dir = fullfile(source,num2str(subs(sub)),'Events');
    for run = runs
    
        fname = fullfile(source_dir,[num2str(subs(sub)) '-' source_cond '-run' num2str(run) '-label-source_raw.fif']);
        if RLflag ==0
            ename = fullfile(event_dir, [num2str(subs(sub)) '-' event_cond, '-run' num2str(run) '-' event_type '.eve']);       
        else
            ename = fullfile(event_dir, [num2str(subs(sub)) '-' event_cond, '-RL-run' num2str(run) '-' event_type '.eve']);
        end 
        data{run} = MEG_load_label_source_trial_RT(fname, ename, sr, prestim, poststim);
    end
    cfg=[];
    Output{sub}.data = ft_appenddata(cfg,data{runs}); %concate different runs into a single fieldtrip structure.

end
fclose('all')

end

