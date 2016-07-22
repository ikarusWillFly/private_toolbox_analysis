function [ROIs, atlas_int] = extract_anatomical_sources(in_cfg,dataSource)
% cfg = [];
% cfg.parameter  = {'pow'};
% cfg.areas      = 'all';
% cfg.mri        = dataSource{1};     % If not specified the data will not be interpolated
% cfg.downsample = dataSource{1}.dim; % If not specified the data will not be interpolated
% cfg.interp_to  = 'mri'; 'dat'       % Interpolate to mri or data itself

% cfg.template   = 'C:\fieldtrip\template\atlas\aal\ROI_MNI_V4.nii';

%TODO: add time dimension
%TODO: solve .avg issue
%TODO: test subset of areas
%TODO: add subset of frequencies
%TODO: add interpolation grid specifications 
%TODO: accept noncell inputs 
%TODO: output dimension
field = 'parameter';    value = {'pow'};
if ~isfield(in_cfg,field), in_cfg.(field) = value; end
field = 'template';     value = 'C:\fieldtrip\template\atlas\aal\ROI_MNI_V4.nii';
if ~isfield(in_cfg,field), in_cfg.(field) = value; end
field = 'areas';        value = 'all';
if ~isfield(in_cfg,field), in_cfg.(field) = value; end
field = 'foi';          value = 1 : numel(dataSource{1}.freq);
if ~isfield(in_cfg,field), in_cfg.(field) = value; end
field = 'mri';          value = dataSource{1};
if ~isfield(in_cfg,field), in_cfg.(field) = value; end
field = 'downsample';   value = 1; 
if ~isfield(in_cfg,field), in_cfg.(field) = value; end
field = 'interp_to';   value = 'mri'; 
if ~isfield(in_cfg,field), in_cfg.(field) = value; end


% select the data to interpolate
int_dat = dataSource{1};
if strcmp(in_cfg.interp_to,'mri') || in_cfg.downsample ~=1;
     interp_data   = 1;
     int_dat       = in_cfg.mri;
else interp_data   = 0;
end

% copy the parameters and remove the avg field
for j = 1 : numel(in_cfg.parameter)
   try 
       dataSource = cellfun(@(x) setfield(x,in_cfg.parameter{j},x.avg.(in_cfg.parameter{j})),dataSource,'uniformoutput', false);
       dataSource = cellfun(@(x) rmfield(x,'cfg'),dataSource,'uniformoutput', false);

   end  
end
dataSource = cellfun(@(x) rmfield(x,'avg'),dataSource,'uniformoutput', false);

%% PREPARE ATLAS                     
atlas_raw           = ft_read_atlas(in_cfg.template);  % load atlas

cfg                 = [];
cfg.parameter       = 'tissue';
cfg.interpmethod    = 'nearest';
cfg.coordsys        = 'mni';
cfg.downsample      = in_cfg.downsample;
atlas_int           = ft_sourceinterpolate(cfg, atlas_raw, int_dat); % interpolate areas indexes 

list_ROIs                                 = [atlas_raw.tissuelabel,{'outside'}]; % add the outside label
atlas_int.tissue(isnan(atlas_int.tissue)) = numel(list_ROIs); % label nans and zeros as outside values
atlas_int.tissue(atlas_int.tissue==0)     = numel(list_ROIs); % label nans and zeros as outside values
interp_ROIs                               = list_ROIs(atlas_int.tissue); 

rois       = in_cfg.rois;
name_rois  = fieldnames(rois);
find_all   = strcmpi(name_rois,'all');
if any(find_all); rois.(name_rois{find_all}) = {list_ROIs}; end

for i_roi = 1 : numel(name_rois)
    areas = rois.(name_rois{i_roi});
    rois.(name_rois{i_roi}) = struct;
    if ischar(areas{1})  % if the cell contains a vector of strings, find the cumulative index
        ind = ismember(interp_ROIs,areas);
        if ~any(ind); error([areas,' not found']); end
        rois.(name_rois{i_roi}).(name_rois{i_roi}) = ind;
    else                 % otherwise find indexes for different areas
        areas = cat(1,areas{:});
        for i_area = 1 : numel(areas)
            ind    = ismember(interp_ROIs,areas(i_area));
            if ~any(ind); error([areas{i_area},' not found']); end
            rois.(name_rois{i_roi}).(areas{i_area}) = ind;
        end
    end
end


%% EXTRACT SOURCE 
n_dt      = numel(dataSource);
clear ROIs
for i_dt = 1 : n_dt
    clc; disp(['N° dataset: ',num2str(i_dt),' of ', num2str(n_dt)])
    dat                 = dataSource{i_dt};  
    
    %%% handle the analysis for a subset of frequencies
    dat.freq            = dat.freq(in_cfg.foi);
    for i_prm = 1 : numel(in_cfg.parameter)
        prm   = in_cfg.parameter{i_prm};
        dat.(prm) = dat.(prm)(:,in_cfg.foi,:);
    end
    %%% interpolate the data frequency wise 
    if interp_data
        for i_fr = 1 : numel(dat.freq);
            %%% build the frequency data and interpolate it
            tmp      = dat;
            tmp.freq = tmp.freq(i_fr);
            for i_prm     = 1 : numel(in_cfg.parameter)
                prm       = in_cfg.parameter{i_prm};
                tmp.(prm) = tmp.(prm)(:,i_fr);
            end
            tmp = ft_sourceinterpolate(struct('parameter',in_cfg.parameter),tmp,int_dat);
            %%% append data frequencies
            for i_prm = 1 : numel(in_cfg.parameter)
                prm   = in_cfg.parameter{i_prm};
                tmp_prm.(prm)(:,:,:,i_fr) = tmp.(prm);
            end
        end
        % append parameters
        for i_prm = 1 : numel(in_cfg.parameter)
            prm   = in_cfg.parameter{i_prm};
            dat.(prm) = tmp_prm.(prm);
        end
    end
    
    for i_roi  = 1 : numel(name_rois)
        roi    = rois.(name_rois{i_roi});
        
        name_areas = fieldnames(roi);
        n_area     = numel(name_areas);   

        for i_area = 1 : n_area  % for each anatomical area
            for i_prms = 1 : numel(in_cfg.parameter)
                prm_name = in_cfg.parameter{i_prms};
                prm      = dat.(prm_name); % size(prm)
                interp_index      = roi.(name_areas{i_area});                  % find interpolated index of selected area size(interp_index)
                if numel(dat.freq) > 1
                    tmp               = squeeze(cellfun(@(x) nanmean(x(interp_index)),num2cell(prm,1:ndims(prm)-1))); % size(prm)
                else
                    tmp               = nanmean(prm(interp_index));
                end
                ROIs.(name_rois{i_roi}).(prm_name)(i_area,:,i_dt)       = tmp;  % size(ROIs.(prm_name)) % size(tmp)
                ROIs.(name_rois{i_roi}).atlas_ind.(name_areas{i_area})  = interp_index;
            end
        end
    end
end
end
