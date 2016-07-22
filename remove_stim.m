function [data,art_samples,art_magnitude] = remove_stim(cfg,data)
% cfg.epoch     str:[pre, during, post] default: pre selecting pre, during or post stim epoch 
% cfg.epSize    double default: 0.05;           size of the epochs to average to find artifact
% cfg.artChan   double default none             channel that shows the artifact
% cfg.negOffset double default: 0.01;           seconds to remove before the first stim pulse
%% input checking
field = 'epoch';    value = '';
if ~isfield(cfg,field), cfg.(field) = value; end
field = 'epSize';    value = 0.05;
if ~isfield(cfg,field), cfg.(field) = value; end
field = 'negOffset';  value = 0.01;
if ~isfield(cfg,field), cfg.(field) = value; end

sm = cfg.epSize*data.fsample;
of = cfg.negOffset*data.fsample;
ch = cfg.artChan;

reshape_dat = @(x) reshape(x(ch,1:floor(size(x,2)/sm)*sm),sm,[]);
find_stim   = @(x) zscore(diff(max(abs(detrend(x,'constant')))));


art         = cellfun(@(x) find_stim(reshape_dat(x)),data.trial,'uniformoutput',0);
artSt       = cellfun(@(x) find(x>2,1)*sm-of,art,'uniformoutput',0);
artEnd      = cellfun(@(x) find(x<-2,1,'last')*sm+of,art,'uniformoutput',0);
artSt(cellfun(@isempty,artSt))   = {nan};
artEnd(cellfun(@isempty,artEnd)) = {nan};
art_samples     = [artSt{:};artEnd{:}]';
art_magnitude   = cellfun(@(x) max(abs(x)),art)';
switch cfg.epoch
    case 'pre'
        art            = art_samples(:,1);
        cutFun         = @(x,y) x(:,1:y);
        if isfield(data,'sampleinfo'); data.sampleinfo(:,2) = data.sampleinfo(:,1) + art; end
    case 'during'
        art            = art_samples;
        cutFun         = @(x,y) x(:,y(1):y(2));
        if isfield(data,'sampleinfo'); data.sampleinfo     = art; end
    case 'post'
        art            = art_samples(:,2);
        cutFun         = @(x,y) x(:,y:end);
        if isfield(data,'sampleinfo'); data.sampleinfo(:,1) = data.sampleinfo(:,2) - art; end
end
if exist('cutFun','var')
    tmpArt      = reshape(num2cell(art,2),size(data.trial));
    data.trial  = cellfun(@(x,y) cutFun(x,y) ,data.trial,tmpArt,'uniformoutput',0);
    data.time   = cellfun(@(x,y) cutFun(x,y) ,data.time, tmpArt,'uniformoutput',0);
    if isfield(data,'trl'); data = rmfield(data,'trl'); end
end
