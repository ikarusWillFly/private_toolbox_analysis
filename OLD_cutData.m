function data = cutData(cfg,data)
% data = cutData(data)
% cut the data to the length of the shortest trial
field = 'minLength';          value = min(cellfun(@length,data.trial));
if ~isfield(cfg,field), cfg.(field) = value; end
field = 'dir';          value = 1;
if ~isfield(cfg,field), cfg.(field) = value; end

minL = cfg.minLength;
dir  = cfg.dir;

%%% remove short trials
shortTr =  cellfun(@(x) size(x,2)<minL,data.trial);
data.trial(shortTr) = [];
data.time(shortTr)  = [];
if isfield(data,'sampleinfo'), data.sampleinfo(shortTr,:) = []; end

switch dir
    case 1
        data.trial      = cellfun(@(x) x(:,1:minL),data.trial,'uniformoutput',false);
        data.time       = cellfun(@(x) x(:,1:minL),data.time,'uniformoutput',false);
        if isfield(data,'sampleinfo')
            data.sampleinfo(:,2)  = data.sampleinfo(:,1) + minL;
        end

    case 2
       data.trial      = cellfun(@(x) x(:,end-minL+1:end),data.trial,'uniformoutput',false);
       data.time       = cellfun(@(x) x(:,end-minL+1:end),data.time,'uniformoutput',false);
       
       if isfield(data,'sampleinfo')
           data.sampleinfo(:,1)  = data.sampleinfo(:,2) - minL;
       end
end
