function [WWgridout] = make_constant_dt_WWgrid(WWgrid,dt);
id = find(diff(WWgrid.time)>2/24);

fnames = fieldnames(WWgrid);
fnames = fnames(~strcmp(fnames,'z'));
fnames = fnames(~strcmp(fnames,'time'));

if nargin<2
dt = nanmin(diff(WWgrid.time));
end

time = WWgrid.time(1):dt:WWgrid.time(end);
[WWgrid.time,id2] = unique(WWgrid.time);

for ii = 1:length(fnames);
    WWgridout.(fnames{ii}) = NaN(length(WWgrid.z),length(time));
    for jj = 1:length(WWgrid.z);
        WWgridout.(fnames{ii})(jj,:) = interp1(WWgrid.time,WWgrid.(fnames{ii})(jj,id2),time);
    end
end

WWgridout.time = time; WWgridout.z = WWgrid.z;
%%

for ii = 1:length(id)
    id2 = find(time>WWgrid.time(id(ii)) & time<WWgrid.time(id(ii)+1));
    for jj = 1:length(fnames);
        WWgridout.(fnames{jj})(:,id2) = NaN;
    end
end

    

