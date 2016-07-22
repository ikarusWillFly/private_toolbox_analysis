function moveData(dataPath,dataPath2,nameFile)
if ~iscell(nameFile), nameFile = {nameFile}; end
if ~strcmpi(dataPath(end),filesep),  dataPath(end+1)  = filesep; end
if ~strcmpi(dataPath2(end),filesep), dataPath2(end+1) = filesep; end

files    = dir(dataPath);
tmp      = cell(size(files));
[tmp{:}] = deal(files(:).name);
ind1 =  ~cellfun(@(x) isdir([dataPath,x]),tmp);
ind2 =  cellfun(@(x) strcmpi(x,'.'),tmp);
ind3 =  cellfun(@(x) strcmpi(x,'..'),tmp);
files(any([ind1,ind2,ind3],2)) = [];

for n_files = 1: numel(nameFile)
    
    nFile = nameFile{n_files};
    for folds = 1 : numel(files)
        tmpPath1     = [dataPath,files(folds).name];
        tmpPath2     = [dataPath2,files(folds).name];
        
        tmpFiles    = dir(tmpPath1);
        tmp         = cell(size(tmpFiles));
        [tmp{:}]    = deal(tmpFiles(:).name);
        toMove      = cellfun(@(x) ~isempty(x),strfind(tmp,nFile));
        cellfun(@(x) movefile([tmpPath1,'/',x],[tmpPath2,'/',x]),tmp(toMove))
    end
end
