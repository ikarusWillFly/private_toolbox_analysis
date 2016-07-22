function dataFilt = dftFilt(data)
fake_sampleinfo = @(d,cont) fun(@(x) x(1:abs(cont-2):end,:),fun(@(x) cat(2,[0;cumsum(x(1:end-1))],cumsum(x(:))-1),repmat(cellfun(@length,d.trial(:)),abs(cont-2),1)))+1;

min_ep_size   = 0.1;
min_length    = round(min_ep_size*data.fsample);
temp          = size(data.trial{1},2);
n_trials      = floor(temp/min_length);
trialinfo     = data.trialinfo;

cfg = [];
cfg.minLength = min_length*n_trials;
dataFilt      = cutData(cfg,data);


tmp     = cat(3,dataFilt.trial{:});
[n_ch,n_sm,n_tr] = size(tmp);
tmp     = reshape(tmp,n_ch,min_length,[]);
dataFilt.trial = shiftdim(num2cell(tmp,[1 2]),+1);clear tmp

tmp     = cat(3,dataFilt.time{:});
tmp     = reshape(tmp,1,min_length,[]);
dataFilt.time  = shiftdim(num2cell(tmp,[1 2]),+1);clear tmp

cfg = [];
cfg.dftfilter = 'yes';
cfg.padding   = 2;
cfg.padtype   = 'mirror';
dataFilt      = ft_preprocessing(cfg,dataFilt);

if isfield(dataFilt,'sampleinfo'); dataFilt = rmfield(dataFilt,'sampleinfo'); end

%%% reshape the trials
tmp     = cat(3,dataFilt.trial{:});
tmp     = reshape(tmp,n_ch,n_sm,n_tr);
dataFilt.trial  = shiftdim(num2cell(tmp,[1 2]),+1);clear tmp

%%% reshape the time
tmp     = cat(3,dataFilt.time{:});
tmp     = reshape(tmp,1,n_sm,n_tr);
dataFilt.time  = shiftdim(num2cell(tmp,[1 2]),+1);clear tmp
dataFilt.trialinfo = trialinfo;
end




% trl  = reshape(cell2mat(cellfun(@(x,z) x:temp:z,num2cell(data.sampleinfo(:,1)),num2cell(data.sampleinfo(:,2)),'uniformoutput',false))',[],2);
% % trl = [0:80:data.sampleinfo(2)]';
% % trl = [ trl(1:end-1)+1 , trl(2:end) ];
% trl(:,3) = 0;
% cfg = [];
% cfg.trl = trl;
% data = ft_redefinetrial( cfg, data );
% % datar = ft_redefinetrial( struct('length', 0.2), datar );
%
% data = ft_preprocessing( struct('dftfilter','yes'), data );
% data.trial = { cat(2,data.trial{:}) };
% data.time = { cat(2,data.time{:}) };
% data.sampleinfo = [ 1 length(data.time{1}) ];
%
% trl = [ 0 cumsum(cellfun(@(x) size(x,2), data.trial))]';
% trl = [ trl(1:end-1)+1 , trl(2:end) ];
% trl(:,3) = 0;
% data = ft_redefinetrial( struct('trl',trl), data );
%
% % trl = length(data.time{1}) * [1:numel(data.trial)];
% % trl = [ [1, trl(1:end-1)]' , [trl-1]' ];
% % trl(:,3) = 0;
% % datar = ft_redefinetrial( struct('trl',trl), datar );
