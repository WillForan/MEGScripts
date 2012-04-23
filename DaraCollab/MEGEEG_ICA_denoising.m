function MEGEEG_ICA_denoising( input, output, ekg_flag)
%Function to do ICA denoising on MEG and EEG data. This function will read in a
%fiff file, do ICA analysis separately on magnetometers and gradiometers,
%identify components highly correlated with EOG and ECG signals (threshold
%set to abs(r)>0.5), then remove those components from the data. Cleaned
%MEGEEG data will be writen to a new fiff file. Note it is assumed input has
%been maxfiltered and reduced to 64 components (see Maxfilter
%publications). This function calls on fieldtrip matlab functions.
%   Usage: MEG_ICA_denoising( input, output)
%   input - file name of input fiff file
%   output - file name of output fiff file
%   ekg_flag - flag to do aggresive ekg removal, lower r threshold to .1
%              1 = on, 0 = off.
%
%Last update 3.23.2012 by Kai


% Load data into fieldtrip structure
cfg.dataset    = input;
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

% Load fiff data and fiff header
[fheader, fdata] = read_fiff(input);

% run ica on EEG
ifg.method = 'runica';
ifg.channel = 'EEG*';
%ifg.runica.pca = 64;
comp = ft_componentanalysis(ifg,data);

ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.5);
if ~ any(ecg_component)&& ekg_flag ==1
    ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.1);
end
if any(ecg_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(ecg_component,2)) ' ECG components ' ]);
end
veog_component = find(abs(corr(data.trial{1}(379,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(veog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(veog_component,2)) ' eye blink components ' ]);
end
heog_component = find(abs(corr(data.trial{1}(378,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(heog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(heog_component,2)) ' saccade components ' ]);
end
%reject artifact components for magnetometers
rfg.component = unique([heog_component,veog_component,ecg_component]);
newdata = ft_rejectcomponent(rfg,comp);

%replace with cleaned data
for n = 1:size(newdata.label,1)
    r = find(strcmp(fheader.info.ch_names',newdata.label(n)));
    fdata(r,:) = newdata.trial{1}(n,:);
end

% run ica on magnetometers
ifg.method = 'runica';
ifg.channel = 'M*1';
ifg.runica.pca = 64;
comp = ft_componentanalysis(ifg,data);

ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.5);
if ~ any(ecg_component)&& ekg_flag ==1
    ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.1);
end
if any(ecg_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(ecg_component,2)) ' ECG components ' ]);
end
veog_component = find(abs(corr(data.trial{1}(379,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(veog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(veog_component,2)) ' eye blink components ' ]);
end
heog_component = find(abs(corr(data.trial{1}(378,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(heog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(heog_component,2)) ' saccade components ' ]);
end

%reject artifact components for magnetometers
rfg.component = unique([heog_component,veog_component,ecg_component]);
newdata = ft_rejectcomponent(rfg,comp);

%replace with cleaned data
for n = 1:size(newdata.label,1)
    r = find(strcmp(fheader.info.ch_names',newdata.label(n)));
    fdata(r,:) = newdata.trial{1}(n,:);
end

% run ica on type 1 gradiometers
ifg.channel = 'M*2';
comp = ft_componentanalysis(ifg,data);

ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.5);
if ~ any(ecg_component)&& ekg_flag ==1
    ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.1);
end
if any(ecg_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(ecg_component,2)) ' ECG components ' ]);
end
veog_component = find(abs(corr(data.trial{1}(379,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(veog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(veog_component,2)) ' eye blink components ' ]);
end
heog_component = find(abs(corr(data.trial{1}(378,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(heog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(heog_component,2)) ' saccade components ' ]);
end

%reject artifact components for type 1 gradiomenters
rfg.component = unique([heog_component,veog_component,ecg_component]);
newdata = ft_rejectcomponent(rfg,comp);

%replace with cleaned data
for n = 1:size(newdata.label,1)
    r = find(strcmp(fheader.info.ch_names',newdata.label(n)));
    fdata(r,:) = newdata.trial{1}(n,:);
end

% run ica on type 2 gradiometers
ifg.channel = 'M*3';
comp = ft_componentanalysis(ifg,data);

ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.5);
if ~ any(ecg_component)&& ekg_flag ==1
    ecg_component = find(abs(corr(data.trial{1}(380,:)',comp.trial{1}(1:64,:)'))>0.1);
end
if any(ecg_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(ecg_component,2)) ' ECG components ' ]);
end
veog_component = find(abs(corr(data.trial{1}(379,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(veog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(veog_component,2)) ' eye blink components ' ]);
end
heog_component = find(abs(corr(data.trial{1}(378,:)',comp.trial{1}(1:64,:)'))>0.5);
if any(heog_component)
    fprintf('\n\n\n')
    disp(['Removing ' num2str(size(heog_component,2)) ' saccade components ' ]);
end

%reject artifact components for type 2 gradiomenters
rfg.component = unique([heog_component,veog_component,ecg_component]);
newdata = ft_rejectcomponent(rfg,comp);

%replace with cleaned data
for n = 1:size(newdata.label,1)
    r = find(strcmp(fheader.info.ch_names',newdata.label(n)));
    fdata(r,:) = newdata.trial{1}(n,:);
end

%write output
%global FIFF;
%if isempty(FIFF)
%   FIFF = fiff_define_constants();
%end
[outfid,cals] = fiff_start_writing_raw(output,fheader.info);
from        = fheader.first_samp;
to          = fheader.last_samp;
quantum_sec = 10;
quantum     = ceil(quantum_sec*fheader.info.sfreq);
%To read the whole file at once set
%quantum     = to - from + 1;

%first_buffer = true;
%for first = from:quantum:to
%    last = first+quantum-1;
%    if last > to
        last = to;
%    end

    fprintf(1,'Writing...');
%    if first_buffer
%       if first > 0
%           fiff_write_float(outfid,FIFF.FIFF_FIRST_SAMPLE,first);
%       end
%       first_buffer = false;
%    end
    fiff_write_raw_buffer(outfid,fdata,cals);
    fprintf(1,'[done]\n');
%end

fiff_finish_writing_raw(outfid);
fclose('all');


