function data = cutData(cfg,data)
% data = cutData(data)
% cut the data to the length of the shortest trial
field = 'minLength';    value = min(cellfun(@length,data.trial));
if ~isfield(cfg,field), cfg.(field) = value; end
field = 'dir';          value = 1;
if ~isfield(cfg,field), cfg.(field) = value; end

minL = cfg.minLength;
dir  = cfg.dir;

fake_sampleinfo = @(d,cont)   bsxfun(@plus,[[0;cumsum(cellfun(@length,reshape(d.trial(2:end),[],1)))], cumsum(cellfun(@length,d.trial(:)))-1],(2-cont*2)*(1:numel(d.trial))');
fake_time       = @(d) cellfun(@(x) (0:length(x)-1)/d.fsample,d.trial,'uniformoutput',false);


%%% remove short trials
shortTr =  cellfun(@(x) size(x,2)<minL,data.trial);
data.trial(shortTr) = [];
data.time(shortTr)  = [];
if isfield(data,'sampleinfo'), data.sampleinfo(shortTr,:) = []; end

switch dir
    case 1 % cut the end of the data
        data.trial      = cellfun(@(x) x(:,1:minL),data.trial,'uniformoutput',false);
        if isfield(data,'trl')
            data.trl(data.trl(:,4) == 3,2) = data.trl(data.trl(:,4) == 1,1) + minL-1;
        end
        
    case 2 % cut the beginning of the data
        data.trial      = cellfun(@(x) x(:,end-minL+1:end),data.trial,'uniformoutput',false);
        if isfield(data,'trl')
            data.trl(data.trl(:,4) == 1,2) = data.trl(data.trl(:,4) == 3,1) - minL+1;
        end
        
end

data.time       = fake_time(data);
data.sampleinfo = fake_sampleinfo(data,0);
end