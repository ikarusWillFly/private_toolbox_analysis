function [dat] = project_anatomical_sources(in_cfg,dataSource,atlas)
% cfg.parameter = 'pow';
% cfg.data      = rand();
% cfg.masking   = ones(size(cfg.data));

field = 'parameter'; value = 'pow';
if ~isfield(in_cfg,field), in_cfg.(field) = value; end

field = 'masking'; value = ones(size(in_cfg.data));
if ~isfield(in_cfg,field), in_cfg.(field) = value; end

field = 'mri';     value = dataSource(1);
if ~isfield(in_cfg,field), in_cfg.(field) = value; end

field = 'downsample';   value = 1; 
if ~isfield(in_cfg,field), in_cfg.(field) = value; end

field = 'interp_to';   value = 'mri'; 
if ~isfield(in_cfg,field), in_cfg.(field) = value; end

int_dat = dataSource(1);
if strcmp(in_cfg.interp_to,'mri') || in_cfg.downsample ~=1;
     interp_data   = 1;
     int_dat       = in_cfg.mri;
else interp_data   = 0;
end

n_freq              = size(in_cfg.data,2);
n_time              = size(in_cfg.data,3);
anatomical_areas    = fieldnames(atlas);
%% PROJECT SOURCES                   
dat                           = dataSource;
try    dat.(in_cfg.parameter)    = dat.(in_cfg.parameter)(:,1);
catch, dat.avg.(in_cfg.parameter)= dat.avg.(in_cfg.parameter)(:,1);
end

cfg                    = [];
cfg.parameter          = in_cfg.parameter;
cfg.interpmethod       = 'nearest';
cfg.coordsys           = 'mni';
cfg.downsample         = in_cfg.downsample;
dat                    = ft_sourceinterpolate(cfg,dat,int_dat);

for tm = 1 : n_time
    for fr = 1 : n_freq
        tmp.dat           = nan(dat.dim);
        tmp.msk           = nan(dat.dim);
        for ar = 1 : numel(anatomical_areas)
            interp_indexes           = atlas.(anatomical_areas{ar});
            tmp.dat(interp_indexes)  = in_cfg.data(ar,fr,tm);
            tmp.msk(interp_indexes)  = in_cfg.masking(ar,fr,tm);
        end
        dat.dat(:,:,:,fr,tm) = tmp.dat;
        dat.msk(:,:,:,fr,tm) = tmp.msk;
    end
end
