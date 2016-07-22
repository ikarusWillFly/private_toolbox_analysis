function hdr = build_header(hdr)
if isstruct(hdr), labels = hdr.label; else labels = hdr; end
%%% elec
elec         = ft_convert_units(ft_read_sens('C:\projects\voraco\toolboxes\fieldtrip\fieldtrip-svn\template\electrode\standard_1005.elc'),'cm');
newOrder     = cell2mat(cellfun(@(x) find(strcmpi(elec.label,x)),labels,'uniformoutput',false));
elec.chanpos = elec.chanpos(newOrder,:);
elec.elecpos = elec.elecpos(newOrder,:);
elec.label   = elec.label(newOrder,:);
hdr.elec     = elec;
%%% layout
cfg = [];
cfg.elec     = elec;
hdr.layout   = ft_prepare_layout(cfg,elec);
%%% neighbours
cfg = [];
cfg.method   = 'triangulation';
cfg.elec     = elec;
cfg.channels = 'EEG';
hdr.neighbor = ft_prepare_neighbours(cfg);

% cat(2,data.label(1:64),hdr.label(1:64),hdr.elec.label,cat(1,{hdr.neighbor.label})')
end