function WWgrid_out = mergefields_WW(WWgrid1,WWgrid2,id1,id2);
%   function dat = mergefields_WW(WWgrid1,WWgrid2,id);
%   Merge structures with data in the standard WWgrid format
% M Hamann 9/14/17
% updated 3/4/18

if nargin<4
    id2 = [];
end
if nargin<3
    id1 = [];
end

vars = fieldnames(WWgrid2);
for ii = 1:length(vars)
    [m,n] = size(WWgrid2.(vars{ii}));
    if n>1
        WWgrid2.(vars{ii}) = WWgrid2.(vars{ii})(:,id2);
    end
end

if isempty(WWgrid1)
    WWgrid_out=WWgrid2;
    return
end


vars = fieldnames(WWgrid1);
if ~isempty(id1)
    for ii = 1:length(vars)
        [m,n] = size(WWgrid1.(vars{ii}));
        if n>1
            WWgrid1.(vars{ii}) = WWgrid1.(vars{ii})(:,id1);
        end
    end
end

WWgrid_out=WWgrid1;

for ii=1:length(vars);
    data1 = getfield(WWgrid1,vars{ii});
    data2 = getfield(WWgrid2,vars{ii});
    
    [M1,N1]=size(data1);
    id1tmp = 1:N1;
    
    [M2,N2]=size(data2);
    id2tmp = 1:N2;
    
    if strcmp(vars{ii},'z')
        if M1>M2, WWgrid_out.z = WWgrid1.z; else WWgrid_out.z = WWgrid2.z; end
    else
        if M1>M2
            data2 =[data2(:,id2tmp);NaN*ones(M1-M2,N2)];
        elseif M2>M1
            data1 =[data1(:,id1tmp);NaN*ones(M2-M1,N1)];
        else
            data1 =data1(:,id1tmp); data2 =data2(:,id2tmp);
        end;
        WWgrid_out = setfield(WWgrid_out,vars{ii},[data1 data2]);
    end
    
    
end;
