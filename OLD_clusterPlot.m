
clu_to_plot = find(cat(1,stat.(param).prob)<=alpha_plot);

for cl = 1 : numel(clu_to_plot)
    clu          = clu_to_plot(cl);
    tmp          = find(stat.([param,'labelmat'])(:)==clu);
    clim         = [min(dat3.(parameter)(tmp)),max(dat3.(parameter)(tmp))];
    [ch, fr, tm] = ind2sub(size(stat.([param,'labelmat'])),tmp);
    freqz        = stat.freq(unique(fr));
    for iPlot = 1 : numel(stat.time)
        
        [ch, fr] = find(stat.([param,'labelmat'])(:,:,iPlot)==clu);
        clc
        fprintf('cluster n %d, timePoint %d ',clu,iPlot);
        fr       = unique(fr); disp(freqz([1 end]))
        ch       = unique(ch); disp(stat.label(any(stat.mask(:,fr,iPlot)',1)))
       if (sum(any(stat.mask(:,fr,iPlot)')) ~=0) || plotAll
        h = subplot(y,x,x*(cl-1)+iPlot);
        cfgPlot                    = [];
        cfgPlot.ylim               = freqz([1 end]);
        cfgPlot.xlim               = stat.time(iPlot) +[-.1 .1];
        cfgPlot.highlight          = 'on';
        cfgPlot.highlightchannel   = stat.label(any(stat.mask(:,fr,iPlot)',1));
        cfgPlot.highlightsize      = 10;
        cfgPlot.highlightcolor     = hlColor;
        cfgPlot.highlightsymbol    = '.';
        cfgPlot.marker             = 'off';
        cfgPlot.comment            = 'no';
        cfgPlot.layout             = chan.layout;
        cfgPlot.colorbar           = 'no';
        cfgPlot.parameter          = parameter;
        cfgPlot.style              = 'both';
        cfgPlot.shading            = 'interp';
        ft_topoplotER(cfgPlot, dat3);
%       ft_topoplotER(cfgPlot, stat);
         set(gca, 'clim',max(abs(clim))*[-1 1])

        if iPlot == numel(stat.time)/2+.5
            title(sprintf('%1.1f Hz - %1.1f Hz\n p-val: %1.3f ',freqz([1 end]),stat.(param)(cl).prob))
        end
%         HP1  = findobj(h,'type','surface');
%         d     = get(HP1, 'CData');       % get data
%         alpha(HP1,alphaLvL(d))                 % based on the enhanced data
        drawnow
       end
    end
end

%  set(gca,'clim',[0 .1])
% ax1  = get(h,'children');
%  HP1  = findobj(h,'type','surface');
%  d = get(HP1, 'CData');       % get data
%  alpha(HP1,(d)*2)             % based on the enhanced data
% opengl software
% set(gcf,'renderer','opengl')
%% finds handles for the figures, the axes and the head plots
% figs = findobj('Type','figure');
% figs = figs(2:-1:1);
% ax1  = get(figs(1),'children');
% ax2  =  get(figs(2),'children');
% HP1  = findobj(figs(1),'type','surface');
% HP2  = findobj(figs(2),'type','surface'); 