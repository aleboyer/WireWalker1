function WWgrid_out = get_WW_data(WWmeta,begtime,endtime)
if endtime<begtime
    warning('Dates are out of order')
    WWgrid_out = [];
    return
end
% Function to grab gridded WW data.
% WWmeta should have fields generated in process_PROJECTNAME.m
%
% begtime and endtime are the range of days to plot (matlab datenum format)
%
% Created by M. Hamann 9/12/17

load(fullfile(WWmeta.data_path,'Index.mat'))
WWgrid_out = [];
id_grab = find(Index.start<endtime & Index.end>begtime);

for ii = id_grab;
    depname = ['d',num2str(ii)];
    load(fullfile(WWmeta.data_path,depname,'WWgrid.mat'),'WWgrid');
    id2 = find(WWgrid.time>=begtime & WWgrid.time<=endtime);
    id1 = [];
    WWgrid_out = mergefields_WW(WWgrid_out,WWgrid,id1,id2);
    clear WWgrid
end

id = find(diff(WWgrid_out.time) ~= 0);
vars = fieldnames(WWgrid_out);
if length(id)<length(WWgrid_out.time)
    for ii = 1:length(vars);
        [m n] = size(WWgrid_out.(vars{ii}));
        if n~=1;
            WWgrid_out.(vars{ii}) = WWgrid_out.(vars{ii})(:,id);
        end
    end
end

id = find(diff(WWgrid_out.time)>(1/24)); 
if~isempty(id);
    for ii = 1:length(vars);
        [m n] = size(WWgrid_out.(vars{ii}));
        if n~=1;
            WWgrid_out.(vars{ii}) = add_nancolumns(WWgrid_out.(vars{ii}),id);
        end
    end
end


