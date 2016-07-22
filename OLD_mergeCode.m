function mergeCode(dataPath,dataPath2,type)
% dataPath  = 'C:\projects\voraco\CMC_Screening';
% dataPath2 = 'V:\projects\voraco\CMC_Screening';
% type = {'copy','merge','mergeSafe','copySafe'};
% mergeCode merges the code present in dataPath (and all its subolders) in to dataPath2 (and all its subfolders)
% the input "type" determine the behavior of the function
% type = 'copy';  the code will automatically be copied from dataPath to dataPath2
% type = 'merge'; the code from both paths will be merged preserving the neweer m_files
% type = '*safe'; added to the type string, the substring "safe" creates a file OLD_<namefile> just before it overwrites a file in dataPath2

type = lower(type);
if ~strcmpi(dataPath(end),filesep),  dataPath(end+1)  = filesep; end
if ~strcmpi(dataPath2(end),filesep), dataPath2(end+1) = filesep; end

folders = regexp(genpath(dataPath), ';', 'split');
folders(cellfun(@isempty,folders)) = [];

for n_files = 1: numel(folders)
    folder1 = folders{n_files};
    folder2 = strrep(folder1,dataPath, dataPath2);
    if ~isdir(folder2), mkdir(folder2);
        warning(sprintf('creating a new directory %s',folder2))  
    end
    merge_mFiles(folder1,folder2,type);
    if strfind(type,'merge')
        merge_mFiles(folder2,folder1,type);
    end
end
end

function merge_mFiles(folder1,folder2,type)
if ~strcmpi(folder1(end),filesep),  folder1(end+1)  = filesep; end
if ~strcmpi(folder2(end),filesep),  folder2(end+1)  = filesep; end

mFiles   = dir([folder1,'*.m']);
tmp      = cell(size(mFiles));
[tmp{:}] = deal(mFiles(:).name);
mFiles   = tmp; clear tmp
for mFl  = 1 : numel(mFiles)
    mFile  = mFiles{mFl};
    mFile1 = [folder1,mFile];
    mFile2 = strrep(mFile1,folder1, folder2);
    % if the file is present in the 2nd directory and it is requested to merge check if the file to copy is newer
    if exist(mFile2,'file')
        tmp1 = dir(mFile1);
        tmp2 = dir(mFile2);
        files      = [tmp1,tmp2];
        date       = cat(1,files.datenum);
        
        switch  strrep(type,'safe','')
            case 'merge'
                if date(1) > date(2)
                    if strfind(type,'safe'), copyfile(mFile2,[folder2,'OLD_',mFile]), end
                    copyfile(mFile1,mFile2)
                warning(sprintf('overwriting %s to %s',mFile1,mFile2))
                end
            case 'copy'
                if strfind(type,'safe'), copyfile(mFile2,[folder2,'OLD_',mFile]), end
                copyfile(mFile1,mFile2)
                warning(sprintf('overwriting %s to %s',mFile1,mFile2))
        end
        
    else % otherwise copy directly
        copyfile(mFile1,mFile2)
    end
end
end

%{
function files = find_directories(dataPath)

files    = dir(dataPath);
tmp      = cell(size(files));
[tmp{:}] = deal(files(:).name);
ind1     =  ~cellfun(@(x) isdir([dataPath,x]),tmp);
ind2     =  cellfun(@(x) strcmpi(x,'.'),tmp);
ind3     =  cellfun(@(x) strcmpi(x,'..'),tmp);
files(any([ind1,ind2,ind3],2)) = [];
end

%}