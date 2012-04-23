function MEG_ICA_denoising( input, output, ekg_flag)
%Function to do ICA denoising on MEG data. This function will read in a
%fiff file, do ICA decomposition separately on magnetometers and
%gradiometers, identify components highly correlated with EOG and ECG
%signals (threshold set to abs(r)>0.5), then project out those components
%from the data. Cleaned MEG data will be writen to a new fiff file. Note it
%is assumed input has been maxfiltered and reduced to 64 components (see
%Maxfilter publications). This function calls on fieldtrip matlab
%functions.
%   Usage: MEG_ICA_denoising( input, output, ekgflag)
%   input - file name of input fiff file
%   output - file name of output fiff file
%   ekg_flag - flag to do aggresive ekg removal, lower number of components
%   to 32 and set r threshold to .02. 1 = on, 0 = off.
%
%Last update 4.22.2012 by Kai

% Load data into fieldtrip structure
cfg.dataset    = input;
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

% Load fiff data and fiff header
[fheader, fdata] = read_fiff(input);

% Identify EOG ECG channels
ecg_channel = find(strcmp(fheader.info.ch_names','ECG063'));
heog_channel = find(strcmp(fheader.info.ch_names','EOG062'));
veog_channel = find(strcmp(fheader.info.ch_names','EOG061'));

ChannelSelection = {  ...
 % cRegexp
 {'M*1'}  % magnetometers
 {'M*2'}  % gradiometers, longitude or latitude
 {'M*3'}  % gradiometers, longitude or latitude
};

for t = 1:length(ChannelSelection)
    cRegexp = ChannelSelection{t}{1};
    ifg.method = 'runica';
    ifg.channel = cRegexp;
    ifg.runica.pca = 64;
    comp = ft_componentanalysis(ifg,data);
    
    ecg_component = find(abs(corr(data.trial{1}(ecg_channel,:)',comp.trial{1}(1:64,:)'))>0.5);
    if ~ any(ecg_component)&& ekg_flag ==1
        ifg.runica.pca = 36;
        comp = ft_componentanalysis(ifg,data);
        
        % reject EKG
        ecg_component = find(abs(corr(data.trial{1}(ecg_channel,:)',comp.trial{1}(1:36,:)'))>0.2);
        if any(ecg_component)
            fprintf('\n\n\n')
            disp(['Removing ' num2str(size(ecg_component,2)) ' ECG components ' ]);
        end
        
        %reject EOG
        veog_component = find(abs(corr(data.trial{1}(veog_channel,:)',comp.trial{1}(1:36,:)'))>0.5);
        if any(veog_component)
            fprintf('\n\n\n')
            disp(['Removing ' num2str(size(veog_component,2)) ' eye blink components ' ]);
        end
        
        %reject EOG
        heog_component = find(abs(corr(data.trial{1}(heog_channel,:)',comp.trial{1}(1:36,:)'))>0.5);
        if any(heog_component)
            fprintf('\n\n\n')
            disp(['Removing ' num2str(size(heog_component,2)) ' saccade components ' ]);
        end
        
        %reject artifact components
        rfg.component = unique([heog_component,veog_component,ecg_component]);
        newdata = ft_rejectcomponent(rfg,comp);
        
        %replace with cleaned data
        for n = 1:size(newdata.label,1)
            r = find(strcmp(fheader.info.ch_names',newdata.label(n)));
            fdata(r,:) = newdata.trial{1}(n,:);
        end
        
    else
        if any(ecg_component)
            fprintf('\n\n\n')
            disp(['Removing ' num2str(size(ecg_component,2)) ' ECG components ' ]);
        end
        
        veog_component = find(abs(corr(data.trial{1}(veog_channel,:)',comp.trial{1}(1:64,:)'))>0.5);
        if any(veog_component)
            fprintf('\n\n\n')
            disp(['Removing ' num2str(size(veog_component,2)) ' eye blink components ' ]);
        end
        heog_component = find(abs(corr(data.trial{1}(heog_channel,:)',comp.trial{1}(1:64,:)'))>0.5);
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
    end
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


