function dataOrd = orderData(data,labels)
new_ord          = labels;
old_ord          = data.label;
% find index
new_index        = cellStrFind(old_ord,new_ord);
new_index        = [new_index(~isnan(new_index));find(isnan(new_index))];

dataOrd = data;
dataOrd.label    = data.label(new_index);
dataOrd.trial    = cellfun(@(x) x(new_index,:),data.trial,'UniformOutput',false);

if isfield(dataOrd,'elec')
    elec = dataOrd.elec;
    elec_index   = cellStrFind(dataOrd.label,elec.label);
    elec_index   = elec_index(~isnan(elec_index));
    elec_index   = new_index(elec_index);
    elec.chanpos = elec.chanpos(elec_index,:);
    elec.elecpos = elec.elecpos(elec_index,:);
    elec.label   = elec.label(elec_index,:);
    dataOrd.elec = elec;
end

function [index, index_mat] = cellStrFind(str1,str2)

if ~iscell(str1), str1 = num2cell(str1,2); end
if ~iscell(str2), str2 = num2cell(str2,2); end
if size(str1,2) > size(str1,1); str1 = str1'; end
if size(str2,2) > size(str2,1); str2 = str2'; end

str1       = cellfun(@lower,str1,'uniformoutput',false);
str2       = cellfun(@lower,str2,'uniformoutput',false);
index_mat  = cell2mat(cellfun(@strcmpi,num2cell(repmat(str1,1,numel(str2)),1),str2','uniformoutput',false));
index      = cellfun(@find,num2cell(index_mat,2),'uniformoutput',false);
tmp        = cell2mat(cellfun(@isempty,index,'uniformoutput',false));
index      = cat(2,index{:})';
index(tmp) = nan;






