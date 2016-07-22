function load_study(cfg)

if ~isstruct(cfg)
    tmp = cfg;
    cfg = [];
    cfg.hd      = 'C';
    cfg.user    = 'voraco';
    cfg.project = tmp;
    clear tmp
else
    field = 'hd'; value = 'C';
    if ~isfield(cfg,field), cfg.(field) = value; end
    field = 'user'; value = 'voraco';
    if ~isfield(cfg,field), cfg.(field) = value; end
end

PTH.sep       = filesep;
PTH.hd        = [cfg.hd,':',PTH.sep];
PTH.user      = [PTH.hd ,'projects',PTH.sep,cfg.user,PTH.sep];
PTH.study     = [PTH.user,cfg.project,PTH.sep];
PTH.code      = [PTH.study,'code',PTH.sep];
PTH.analysis  = [PTH.code,'analysis',PTH.sep];

if isdir(PTH.analysis)
    loadPath  = PTH.analysis;
else
    loadPath  = PTH.code;
end

PTH.tbx       = ['C:/projects/voraco/toolboxes',PTH.sep];
PTH.pvt       = [PTH.tbx,'private_toolbox',PTH.sep];
refreshEditor,
openScripts(loadPath)
end

function openScripts(path)
if nargin < 1; path = cd; end
files = dir([path,'*.m']);
files = cat(1,{files.name});
cellfun(@(x) edit([path,x]),files);
end