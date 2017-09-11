function [hf,ha] = plot_WW_RBRgrid(gridin,begtime,endtime,vars);
%{'T','S','BScat','F_chla','DO'};

if nargin<4
    vars = {'T','S','BScat','F_chla','DO'};
end

id = find(gridin.time>=begtime & gridin.time<=endtime);

if size(gridin.z,2)~=1
    gridin.z = gridin.z';
end

isu = strcmp(vars,'u');
isu2 = find(isu == 1);
isv = strcmp(vars,'v');
isw = strcmp(vars,'w');
if ~isempty(isu2);
    isu3 = find(~isnan(gridin.u(:,id)));
    if isempty(isu3)
        vars2 = vars(isu==0 & isv==0 & isw==0);
        vars = vars2;
    end
end
n = length(vars);

hf = figure(153); clf; tallfigure;
ha = MySubplot(0.05,0.15,0,0.05,0.1,0.02,1,n);

for ii = 1:n
    axes(ha(ii));
    pcolor(gridin.time(id),gridin.z,gridin.(vars{ii})(:,id));
    shading flat; axis ij
    
    c = cbstay;
    
    if strcmp(vars{ii},'T'); caxis([8 20]); ylabel(c,'Temp, {}^\circ{C}'); colormap(gca,'jet')
    elseif strcmp(vars{ii},'S'); caxis([33 34]); ylabel(c,'Sal, psu'); colormap(gca,redblue)
    elseif strcmp(vars{ii},'rho'); caxis([1024 1026.5]); ylabel(c,'\rho, kg m^{-3}'); 
    elseif strcmp(vars{ii},'BScat'); caxis([100 500]); ylabel(c,'Backscatter'); colormap(gca,hot)
    elseif strcmp(vars{ii},'F_chla'); caxis([50 300]); ylabel(c,'Chl, volts');colormap(gca,copper)
    elseif strcmp(vars{ii},'DO'); caxis([40 100]); ylabel(c,'DO, %'); colormap(gca,'jet')
    elseif strcmp(vars{ii},'u'); caxis([-0.25 0.25]); ylabel(c,'u, m/s'); colormap(gca,redblue)
    elseif strcmp(vars{ii},'v'); caxis([-0.25 0.25]); ylabel(c,'v, m/s'); colormap(gca,redblue)
    elseif strcmp(vars{ii},'w'); caxis([-0.05 0.05]); ylabel(c,'w, m/s'); colormap(gca,redblue)
    else ylabel(c,vars{ii})
    end
    
    if ii == n
        datetick
    else
        set(gca,'xticklabel',[])
    end
    if ii == 1
        title([datestr(begtime),' to ',datestr(endtime)])
    end
end