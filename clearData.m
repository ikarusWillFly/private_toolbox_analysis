function clearData(dataPath,nameFile,recycleBinFlag)
% set recycleBinFlag to 0 if you want to directly delete the data 
% possible uses
% clearData(PTH.data,'S_FFT',1) 
% clearData(PTH.data,{'alpha','beta'},1)

if nargin < 3, recycleBinFlag = 1; end
if ~strcmpi(dataPath(end),filesep), dataPath(end+1) = filesep; end

if recycleBinFlag ~= strcmpi(recycle,'on') % if the flag is different to the status of the recycle
    if recycleBinFlag                      % if the recycle has to be set to on
        recycle('on') 
    else                                   % otherwise
        recycle('off')
    end
end

files    = dir(dataPath);
tmp      = cell(size(files));
[tmp{:}] = deal(files(:).name);
ind1 =  ~cellfun(@(x) isdir([dataPath,x]),tmp);
ind2 =  cellfun(@(x) strcmpi(x,'.'),tmp);
ind3 =  cellfun(@(x) strcmpi(x,'..'),tmp);
files(any([ind1,ind2,ind3],2)) = [];

subjFolders = files;
for sb = 1 : numel(subjFolders)
    sbDir   = [dataPath,subjFolders(sb).name,filesep];
    sbFiles = [];
    for kw = 1 : numel(nameFile)
        tmp = nameFile(kw); if iscell(tmp) tmp = tmp{:}; end
        tmpFiles = dir([sbDir,tmp,'*']);
        sbFiles  = cat(2,sbFiles,{tmpFiles.name});
    end
    sbFiles = unique(sbFiles);
    cellfun(@(x) delete([sbDir,x]),sbFiles)
end
end



%{
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
%}