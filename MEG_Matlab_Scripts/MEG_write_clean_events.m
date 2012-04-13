function MEG_write_clean_events( events, stim, run )
%To write new events file after cleaning out trials with artifact
%   Input: events - structure of mne event file format, free of artifact
%   trials. And has a RT column at the end
%          stim - the prefix, i.e. 10606-ANTI
%          run - run number
%   Will generate two event files, one with RT on without.

fname=strcat(stim,'-run',num2str(run),'-Clean-RT-All.eve');
dlmwrite(fname, events, 'delimiter', '\t',  'precision', 10);

events(:,end)=[];
fname=strcat(stim,'-run',num2str(run),'-Clean-All.eve');
dlmwrite(fname, events, 'delimiter', '\t',  'precision', 10);

end

