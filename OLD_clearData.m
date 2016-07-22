function clearData(dataPath,nameFile)
if ~strcmpi(dataPath(end),filesep), dataPath(end+1) = filesep; end

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
        tmpPath     = [dataPath,files(folds).name];
        tmpFiles    = dir(tmpPath);
        tmp         = cell(size(tmpFiles));
        [tmp{:}]    = deal(tmpFiles(:).name);
        toKeep      = cellfun(@isempty,strfind(tmp,nFile));
        tmp(toKeep) = [];
        cellfun(@(x) delete([tmpPath,'/',x]),tmp)
    end
end
