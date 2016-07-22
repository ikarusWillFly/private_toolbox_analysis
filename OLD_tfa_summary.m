function tfa_summary(prm)
roundTo  = @(number,precision) round(number*(1/precision))*precision;
colors   = {'r';'b'}; alphas   = [.2,.2];
textSpec = {'fontweight','bold'};

foi         = prm.foi;
smoothing   = prm.tapsmofrq;
t_ftimwin   = prm.t_ftimwin;

plot(foi,zeros(size(foi)),'.r'), hold on
ax = plotyy(foi,smoothing,foi,t_ftimwin);
set(ax,{'ycolor'},colors)

set(gcf, 'CurrentAxes', ax(1));
l = findobj(gca,'type','line'); set(l,'linestyle','none');
patch([foi,fliplr(foi)],[max(smoothing),fliplr(min(smoothing))],colors{1},'edgealpha',0,'facealpha',alphas(1))
yLim = get(gca,'ylim');
set(gca,'xtick',[])

set(gca,'ytick',roundTo(linspace(yLim(1),yLim(end),10),.1))
plot(repmat(foi,2,1),smoothing,':k');

set(gcf, 'CurrentAxes', ax(2));
l = findobj(gca,'type','line'); set(l,'linestyle','none');
patch([foi,fliplr(foi)],[max(t_ftimwin),fliplr(min(t_ftimwin))],colors{2},'edgealpha',0,'facealpha',alphas(2))
set(gca,'xtick',floor(foi(1:10:end)))
yLim = get(gca,'ylim');
set(gca,'ytick',roundTo(linspace(yLim(1),yLim(end),10),.1))

title('SUMMARY TIME FREQUENCY ANALYSIS',textSpec{:})
xlabel('CENTRAL FREQUENCY',textSpec{:})
ylabel(ax(1),'SMOOTHING',textSpec{:})
ylabel(ax(2),'TIME FREQUENCY WINDOW',textSpec{:})

end