function datOut = slidingEpochs(cfg,datIn)
%%% INPUTS and DEFAULTS
% cfg.time_dimension  = 1;      % time dimension
% cfg.trial_dimension = 4;      % trial dimension
% cfg.epoch_size      = 10;     % desired epoch sizes (in samples)
% cfg.sliding         = 4;      % desired sliding size (in samples)
% cfg.keeptrials      = false;  % flag to keep the trials separated
% cfg.feedback        = false;  % flag to receive feedback with datadimensions
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
field = 'time_dimension';     value  = 1;
if ~isfield(cfg,field), cfg.(field)  = value; end
field = 'trial_dimension';     value = 4;
if ~isfield(cfg,field), cfg.(field)  = value; end
field = 'sliding';             value = cfg.epoch_size/2;
if ~isfield(cfg,field), cfg.(field)  = value; end
field = 'keeptrials';          value = true;
if ~isfield(cfg,field), cfg.(field)  = value; end
field = 'feedback';            value = false;
if ~isfield(cfg,field), cfg.(field)  = value; end


% datIn = nan(500,2,2,10);
start_time = tic;
ep                  = cfg.epoch_size;    
sl                  = cfg.sliding;    
ti_dm               = cfg.time_dimension;   
tr_dm               = cfg.trial_dimension;    
keeptrials          = cfg.keeptrials;
%% prepare matrix
mat_sz   = size(datIn);                                     % get the original mat size
ot_dm    = setxor([ti_dm,tr_dm],1:ndims(datIn));            % get the not used dimensions
new_dm   = [ti_dm,tr_dm,ot_dm];                             % get the new dimension order
datOut   = num2cell(permute(datIn,new_dm),[1 2]);           % change the dimord and insert timeXtrial in to cells
%% find indexes
tr_sz    = size(datOut{1});                                 % get the size of the timeXtrial matrix
sl_ind   = (-ep/2+1:ep/2)';                                 % get the sliding index
ep_ind   = ep/2:sl:tr_sz(1)-ep/2;                           % get the epochs index
ti_ind   = bsxfun(@plus,sl_ind,ep_ind);                     % make the sliding index for each epoch of the first trial
tr_ind   = (0:(tr_sz(2)-1)).*tr_sz(1);                      % get the trials index
mat_ind  = bsxfun(@plus,ti_ind,shiftdim(tr_ind,-1));        % find the index for the whole timeXtrial cell
%% cut matrix 
datOut   = cellfun(@(x) reshape(x(mat_ind),size(mat_ind)),datOut,'uniformoutput',false); % get the sliding data from the matrix
datOut   = cat(4,datOut{:});                                % get the matrix out of the cell
datOut   = reshape(datOut,[size(mat_ind),mat_sz(ot_dm)]);   % reshape to recover the lost dimension from decelling
sz       = size(datOut);                                    % get the size of the matrix

if ~keeptrials                                                 % if the trials have to be merged
    datOut  = reshape(datOut,[sz(1),prod(sz(2:3)),sz(4:end)]); % cat the trials
end

if cfg.feedback
fprintf('The data dimension is %d sliding epochs of %d samples.\n',sz(2),sz(1))
fprintf('Time required to cut the data is %1.1f seconds\n',toc(start_time))
end

