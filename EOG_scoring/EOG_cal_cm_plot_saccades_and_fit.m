fit_fig = figure;
hold on;
set(gcf,'numbertitle','off');
saccades={'-210','-160','-110','-60','60','110','160','210'};
% extract the EOG values for each type of saccade
for sac = 1:8
   for sq = 1:4
      saccade_values(sq,sac)=sequence_values{sq}(find(strcmp(sequence_labels,saccades{sac})));
   end
end
saccade_values
for sac=1:8
   % include only non-zero values (zero means it was discarded by the human operator)
   valid_saccades=find(saccade_values(:,sac)~=0);
   mean_saccade(sac)=nanmean(saccade_values(valid_saccades,sac));
   std_saccade(sac)=nanstd(saccade_values(valid_saccades,sac));
   median_saccade(sac)=nanmedian(saccade_values(valid_saccades,sac));
end
% plot a graph of EOG deflections vs. saccade size
X_screen = [110 160 210 260 380 430 480 530]-320;
x_values=X_screen * 0.1183;
plot(x_values,mean_saccade,'ok','linewidth',3);
errorbar(x_values,mean_saccade,std_saccade,'ok');
plot(x_values,saccade_values,'or');
plot(x_values,zeros(1,8),'ow');
set(gca,'ytick',get(gca,'ytick')*1.1);
% fit saccade data to a first degree polynomial (linear fit)
fit_params = polyfit(x_values,mean_saccade,1);
plot(-30:1:30,polyval(fit_params,-30:1:30),'color','black','linestyle','--')
%set(gca,'xtick',[-15 -10 -5 0 5 10 15],'xticklabel',[saccades(1:3) ' ' saccades(4:6)]);
xlabel('Eye Movement (cm)');
ylabel('Horizonal EOG (Microvolt)')