close all; %close all figures, use i for figure num
outdir = '~/motMov/';
if ( ~ exist(outdir,'dir') )
 mkdir(outdir)
end

% runs = dir('*_raw_sss.fif');
runs = dir('*ds_sss_raw.fif'); % OK to use ds now
for i=1:length(runs)
   [head,fif] = read_fiff(runs(i).name);
   [displacement, motion_movie ] = MEG_mean_dist(head,fif);
   name=runs(i).name(1:end-12); % _raw_ss.fif = 12 chars
   movie2avi(motion_movie, [outdir name '.avi']) %20M per file :(
   [n,x] = hist(displacement(find(displacement)));
   bar(x,n);
   hgexport(i,[outdir name '_hist.eps']);

   txtout = fopen([outdir name '.txt'],'w');
   fprintf('\n\n# %s\n',name);

   fprintf(txtout,'# min\tmax\tmean\tstd\tvar (mm)\n');
   fprintf(txtout,'%.2f\t',[min(displacement) max(displacement) mean(displacement) std(displacement) var(displacement)].*1000);
   fprintf(txtout,'\n');

   fprintf(txtout, '# hist value(mm)/count\n');
   fprintf(txtout,'%.2f\t',x.*1000);
   fprintf(txtout,'\n');
   fprintf(txtout,'%i\t',n);
   fprintf(txtout,'\n');

   system(['cat ' outdir name '.txt']);


end

