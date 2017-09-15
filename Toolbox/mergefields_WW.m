function WWgrid_out = mergefields_WW(WWgrid1,WWgrid2,id1,id2);
%   function dat = mergefields_WW(WWgrid1,WWgrid2,id);
%   Merge structures with data in the standard WWgrid format
% M Hamann 9/14/17

if nargin<4
    id2 = [];
end
if nargin<3
    id1 = [];
end

if isempty(WWgrid1)
    WWgrid_out=WWgrid2;
    names = fieldnames(WWgrid2);
    for ii=1:length(names);
        data2 = getfield(WWgrid2,names{ii});
        [M2,N2]=size(data2);
        if ~isempty(id2)
            N2 = length(id2);
            id2tmp = id2;
        else
            id2tmp = 1:N2;
        end
        if strcmp(names{ii},'z')
            WWgrid_out.z = WWgrid2.z;
        else
            WWgrid_out = setfield(WWgrid_out,names{ii},data2(:,id2tmp));
        end
    end
    
    return;
end;

names = fieldnames(WWgrid1);
WWgrid_out=WWgrid1;

for ii=1:length(names);
    data1 = getfield(WWgrid1,names{ii});
    data2 = getfield(WWgrid2,names{ii});
    [M1,N1]=size(data1);
    if ~isempty(id1)
        N1 = length(id1);
        id1tmp = id1;
    else
        id1tmp = 1:N1;
    end
    
    [M2,N2]=size(data2);
    if ~isempty(id2)
        N2 = length(id2);
        id2tmp = id2;
    else
        id2tmp = 1:N2;
    end
    
    if strcmp(names{ii},'z')
        if M1>M2, WWgrid_out.z = WWgrid1.z; else WWgrid_out.z = WWgrid2.z; end
    else
        if M1>M2
            data2 =[data2(:,id2tmp);NaN*ones(M1-M2,N2)];
        elseif M2>M1
            data1 =[data1(:,id1tmp);NaN*ones(M2-M1,N1)];
        else
            data1 =data1(:,id1tmp); data2 =data2(:,id2tmp);
        end;
        WWgrid_out = setfield(WWgrid_out,names{ii},[data1 data2]);
    end
    
    
end;
