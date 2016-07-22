function newData = orderData(data,hdr)
new_ord             = hdr.label;
old_ord             = data.label;

[members,new_index] = ismember(new_ord,old_ord);
new_index           = new_index(members);

newData = data;
newData.label       = data.label(new_index);
newData.trial       = cellfun(@(x) x(new_index,:),data.trial,'UniformOutput',false);

if isfield(newData,'elec')
    try 
        newData.elec = hdr.elec;
    catch
        elec = newData.elec;
        elec_index   = cellStrFind(newData.label,elec.label);
        elec_index   = elec_index(~isnan(elec_index));
        elec_index   = new_index(elec_index);
        elec.chanpos = elec.chanpos(elec_index,:);
        elec.elecpos = elec.elecpos(elec_index,:);
        elec.label   = elec.label(elec_index,:);
        newData.elec = elec;
    end
end

end
