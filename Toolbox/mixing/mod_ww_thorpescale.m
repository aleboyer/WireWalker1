function Profile=mod_ww_thorpescale(Profile)
% compute the thorpe scale from classic definition TODO define Thorpe scale
% and thorpe scale from Jerry Smith AOPE approach
% outputs: The 2 kind of thorpe's scale and the estimate epsilon associated

%Profile comes from WireWalker master processing
% sampling frequency
df=1/nanmean(diff(Profile.ctdtime))/86400;

% Create approximate time base, assuming df as the sample frequency. df should ~6 Hz.
startnum = Profile.ctdtime(1);% From the raw data file name.
% define Pressure
Pressure   = Profile.P;
Salinity   = Profile.S;
Temperature= Profile.T;
Lupcast=length(Pressure);
ztime = startnum + (1:Lupcast)'/(df*3600*24);%datenum within a few seconds

% Jerry has an atmospheric correction which I do not have.
%TODO include this when it is available.

% % Next correct the depth for atmospheric pressure anomaly:
% % "standard pressure" is 1013.25 millibars, and the pressure sensor is
% % about 8.75 cm below the thermistor. 1 mb ~ 1 cm, so 1013.25-8.75=1004.5
% 	zpress = linterp(wtime,airpress,ztime);
% 	Depth = Depth + 0.01*(1004.5-zpress);
Depth=Pressure;

%== Test Salinity-spiking by just putting in constant S = 33.33 == versus:
Salmed = medfilt1(Salinity,8,'truncate');% cut most spikes.


tic
dy = 6*3600*24;% a full day of samples at 6 Hz


%% extract monotonic upcasts using next shallower points
% Store stats for each overturn- hope there are <100 overturns:
cntover   = zeros(1,400);
timover   = zeros(1,400);
Lthorpe   = zeros(1,400);
Lthoraw   = zeros(1,400);
Lover     = zeros(1,400);
Tover     = zeros(1,400);
Sover     = zeros(1,400);
rhorms    = zeros(1,400);
Nover     = zeros(1,400);
msortover = zeros(1,400);
mrawover  = zeros(1,400);
Neqvover  = zeros(1,400);
Napeover  = zeros(1,400);
drdzover  = zeros(1,400);
topover   = zeros(1,400);
apeover   = zeros(1,400);
epsA      = zeros(1,400);
epsTh     = zeros(1,400);

badix=[];
dep = Depth(1);
for jj = 2:Lupcast
    if(Depth(jj) > dep - 1e-3) % demand at least 1 mm.
        badix = [badix jj];
    else
        dep = Depth(jj);
    end
end
upcast=1:Lupcast;
upcast(badix)=[];

% Ready to implement Thorpe-scaling & AOPE for dissipation?
nmax  = length(upcast);
zn    = -Depth(upcast);
delz  = ones(nmax,1);
delz(1:nmax-1) = diff(zn);% use layer thickness above zn
delz(nmax)     = delz(nmax-1);  % fake the last one
Tn = Temperature(upcast);
Sn = Salmed(upcast);% medfilt1 all beforehand!!
rho = dense(Tn,Sn,0); % sigma-0

% Sort by density
[rhs,nt] = sort(rho,'descend');
delsort = delz(nt);% Re-sort the layer thicknesses too, sum from z1 to
zsort = cumsum([zn(1); delsort(1:nmax-1)]);% match bottom-most extent.

% d(rho)/dz across each layer: NO averaging! Makes Nbar worse, not better.
drhodz = zeros(size(rhs));
drhodz(1:nmax-1) = (rhs(1:nmax-1)-rhs(2:nmax))./delsort(1:nmax-1);
drhodz(nmax) = drhodz(nmax-1);% fake the last point again

% Now adjust depths to mid-layer depths: do NOT interpolate densities!
zn = zn + 0.5*delz;
zsort = zsort + 0.5*delsort;

% After this adjustment, calculate the Thorpe displacements:
zT = zn(nt)-zn;  % 'raw' Thorpe displacements; not correct,
sumT = cumsum(zT);% but guaranteed to sum to zero!
zTh = zn(nt) - zsort; % Note zTh instead of zT
sumTh = cumsum(zTh.*delsort);% This does converge to zero... yay!

% Look for the top of the overturn touching the surface, as near as we can tell
mix = find(sumT(1:nmax-4) < 1e-3,1,'last');
mixd = zn(mix);
mixt = ztime(upcast(mix));
% 
ocnt = 1;% count the number of overturns in each upcast
Thorpeps = zeros(size(upcast));
APEeps = zeros(size(upcast));
n0=1; ns=1;
while ~isempty(ns)
    ns = find(rho(n0:nmax)~=rhs(n0:nmax),1,'first');%find next overturn above n0
    ns = ns+n0-1;% adjust to 'upcast' index
    if(~isempty(ns))
        nf=find(sumT(ns:nmax)<1e-3,1,'first');%find the final point in the overturn
        nf=nf+ns-1;% adjust to 'upcast' index
        nx=ns:nf; % all the points in the overturn
        Loverturn = sum(delz(nx));
        sumTh(nx) = sumTh(nx)/Loverturn;% "Normalize" sumTh by the weights
        sumT(nx) = sumT(nx)*(mean(delz(nx))/Loverturn);% "Normalize" sumT too
        
        robar = sum(delz(nx).*rho(nx))/Loverturn;% note: sigmaT. ALB mean density inside the overturn
        drdzbar=sum(delsort(nx).*drhodz(nx))/Loverturn;
        % get slopes of LSF lines fit to raw and sorted densities. First raw
        znbar = sum(delz(nx).*zn(nx))/Loverturn;% Note zn < 0 !!
        zn2bar = sum(delz(nx).*zn(nx).^2)/Loverturn;
        znrhobar = sum(delz(nx).*zn(nx).*rho(nx))/Loverturn;
        mraw = -(znrhobar - robar*znbar)/(zn2bar - znbar^2);
        % Then the sorted LSF value: does it match drdzbar?
        zsbar = sum(delsort(nx).*zsort(nx))/Loverturn;
        zs2bar = sum(delsort(nx).*zsort(nx).^2)/Loverturn;
        zsrhsbar = sum(delsort(nx).*zsort(nx).*rhs(nx))/Loverturn;
        msort = -(zsrhsbar - robar*zsbar)/(zs2bar - zsbar^2);
        
        robar = robar +1000; % convert sigma to rho
        Nbar = sqrt(9.8*drdzbar/robar);% for reference (saved).
        
        LT2 = sum(delz(nx).*zT(nx).^2)/Loverturn;% for reference only!
        LTh2 = sum(delsort(nx).*zTh(nx).^2)/Loverturn;% redone right...
        % Use 'equivalent linear stratification' like Mater et al.
        msDrho = sum(delz(nx).*(rho(nx)-rhs(nx)).^2)/Loverturn;
        drdzeqv = sqrt(msDrho/LTh2);
        Neqv = sqrt(9.8*drdzeqv/robar);
        epsT = 0.64*LTh2*Neqv^3; %The Thorpe-scale estimate
        % This works now... could use znrhobar & zsrhsbar ...
        ape=(9.8/(robar*Loverturn))* ...
            ( sum(delz(nx).*zn(nx).*rho(nx)) ...
            - sum(delsort(nx).*zsort(nx).*rhs(nx)) );
        if(ape<0), error('negative AOPE'); end
        
        Nape = sqrt(2*ape/LTh2);% equivalent linear strat. from AOPE
        epsPE = 1.28*Nape*ape;
        % 			epsPE = 0.64*(2*ape)^1.5/sqrt(LTh2);% all the same...
        %			epsPE = 1.81*ape^1.5/sqrt(LTh2);
        % Use Nape for Thorpe-scale estimate too, instead of Neqv?
        % 			epsT = 0.64*LTh2*Nape^3; %The Thorpe-scale estimate
        % No. This merely forces them to be the same.
        
        Thorpeps(nx)=epsT.*ones(size(nx));
        % Don't know why this is smaller than epsT... must be N?
        APEeps(nx) = epsPE*ones(size(nx));
        
        % Store stats for each overturn- know there are <= 100 overturns:
        cntover(ocnt) = length(nx);
        timover(ocnt) = mean(ztime(upcast(nx)));
        Lthorpe(ocnt) = sqrt(LTh2);
        Lthoraw(ocnt) = sqrt(LT2);
        Lover(ocnt) = Loverturn;
        Tover(ocnt) = mean(Tn(nx));
        Sover(ocnt) = mean(Sn(nx));
        rhorms(ocnt)= sqrt(msDrho);
        Nover(ocnt) = Nbar;
        Neqvover(ocnt) = Neqv;
        Napeover(ocnt) = Nape;
        drdzover(ocnt) = drdzbar;
        msortover(ocnt) = msort;
        mrawover(ocnt) = mraw;
        topover(ocnt) = zn(nf);
        apeover(ocnt) = ape;
        epsA(ocnt) = epsPE;
        epsTh(ocnt) = epsT;
        ocnt = ocnt+1;
        % on to the next overturn in the upcast
        n0 = nf+1; % Onward!
    end
end

Profile.nb_overturn=ocnt;
Profile.ztop_overturn=topover(ocnt);
Profile.depthLT=Depth(upcast);
Profile.epsiLT=Thorpeps;
Profile.epsiAPE=APEeps;
Profile.LT=Lthorpe;
Profile.APE=apeover;
Profile.mixd=mixd;
Profile.mixt=mixt;

end

% Try scatter3(x,y,z,s,c) with view(2)=view(0,90)?
%% First scale temperature to indexes 1 to 64 from °C
% tmin=9.5;
% tmax=16.5;
% tcolor = round((Temperature(upix)-tmin)*64/(tmax-tmin));
% top = find(tcolor<1); tcolor(top)=ones(size(top));
% top = find(tcolor>64); tcolor(top)=64*ones(size(top));
% 
% setfiguresize(8,4,100);
% figure(17);clf;
% % Now define the colormap with the same size (64)
% % cmap = colormap([flipud(jetwb(32)); jetwb(32)]);
% cmap17 = colormap([parula(24); jetwb(40)]);
% colormap(17,cmap17);
% scatter3(ztime(upix),-Depth(upix),-tcolor,1,cmap17(tcolor,:),'.');
% view(2); set(gca,'color',[.94 .94 .94]);
% xlim([ztime(upix(1)) ztime(upix(length(upix)))]);
% set(gca,'TickDir','out');
% if(length(ix)<=2*dy)
% 	datetick('x','dd-HH','keeplimits');
% 	xlabel('Day-Hour (UTC)');
% else
% 	datetick('x','mm/dd','keeplimits');
% 	xlabel('Month/Day (UTC)');
% end
% ylabel('Depth (m)');
% ylim([-93 0]);
% % ylim([-95 0]);
% title('Upcast Temperatures (°C)');
% grid on;
% hold on;
% scatter3(mixt(:),mixd(:),-mixd(:),64,[0 0 0],'.');
% 
% cb17=colorbar('TickLabels',tmin:(tmax-tmin)/7:tmax,'Ticks',0:(1/7):1); 
% cb17.Label.String='Temperature (°C)';
% cb17.TickDirection='both';
% colormap(cb17,cmap17);
% drawnow;

% %% First scale density to indexes 1 to 64 from kg/m^3
% sigma = dense(Temperature,Salmed,0); % sigma-0
% sigmin=24.25;
% sigmax=26.0;
% scolor = round((sigma(upix)-sigmin)*64/(sigmax-sigmin));
% top = find(scolor<1); scolor(top)=ones(size(top));
% top = find(scolor>64); scolor(top)=64*ones(size(top));
% 
% setfiguresize(8,4,100);
% figure(17);clf;
% % Now define the colormap with the same size (64)
% cmap17 = colormap(flipud([parula(24); jetwb(40)]));
% colormap(17,cmap17);
% scatter3(ztime(upix),-Depth(upix),-scolor,1,cmap17(scolor,:),'.');
% view(2); set(gca,'color',[.94 .94 .94]);
% xlim([ztime(upix(1)) ztime(upix(length(upix)))]);
% set(gca,'TickDir','out');
% if(length(ix)<=2*dy)
% 	datetick('x','dd-HH','keeplimits');
% 	xlabel('Day-Hour (UTC)');
% else
% 	datetick('x','mm/dd','keeplimits');
% 	xlabel('Month/Day (UTC)');
% end
% ylabel('Depth (m)');
% ylim([-93 0]);
% % ylim([-95 0]);
% % title('Upcast Temperatures (°C)');
% grid on;
% hold on;
% scatter3(mixt(:),mixd(:),-mixd(:),64,[0 0 0],'.');
% 
% cb17=colorbar('TickLabels',sigmin:(sigmax-sigmin)/7:sigmax,'Ticks',0:(1/7):1); 
% cb17.Label.String='sigma (kg/m^3)';
% cb17.TickDirection='both';
% cb17.Direction='reverse';
% colormap(cb17,cmap17);
% drawnow;
% 
% %% then scale epsilon to indexes 1 to 64 
% emin= -10;
% emax= -5;
% ecolor = round((log10(epsLT)-emin)*64/(emax-emin));
% top = find(ecolor<1); ecolor(top)=ones(size(top));
% top = find(ecolor>64); ecolor(top)=64*ones(size(top));
% 
% figure(18);clf;
% % Define another colormap for epsilon
% cmap18 = colormap(jetwb(64));
% colormap(18,cmap18);
% ah18=scatter3(ztime(upix),-Depth(upix),-ecolor,1,cmap18(ecolor,:),'.');
% view(2); set(gca,'color',[.94 .94 .94]);
% xlim([ztime(upix(1)) ztime(upix(length(upix)))]);
% set(gca,'TickDir','out');
% if(length(ix)<=2*dy)
% 	datetick('x','dd-HH','keeplimits');
% 	xlabel('Day-Hour (UTC)');
% else
% 	datetick('x','mm/dd','keeplimits');
% 	xlabel('Month/Day (UTC)');
% end
% ylabel('Depth (m)');
% ylim([-93 0]);
% title('Upcast Thorpe-Scale Dissipation');
% grid on;
% hold on;
% scatter3(mixt(:),mixd(:),-mixd(:),64,[0 0 0],'.');
% 
% cb18=colorbar('TickLabels',emin:(emax-emin)/10:emax,'Ticks',0:.1:1); 
% cb18.TickDirection='both';
% cb18.Label.String='Log10(epsilon)';
% colormap(cb18,cmap18);
% drawnow;
% 
% %% Now plot the AOPE based eps estimate
% % Empirically, it looks like epsAPE is about 10% smaller.
% emin= -10;
% emax= -5;
% ecolor = round((log10(epsAPE) -emin)*64/(emax-emin));
% top = find(ecolor<1); ecolor(top)=ones(size(top));
% top = find(ecolor>64); ecolor(top)=64*ones(size(top));
% 
% figure(19);clf;
% colormap(19,cmap18);
% ah19=scatter3(ztime(upix),-Depth(upix),-ecolor,1,cmap18(ecolor,:),'.');
% view(2); set(gca,'color',[.94 .94 .94]);
% xlim([ztime(upix(1)) ztime(upix(length(upix)))]);
% set(gca,'TickDir','out');
% if(length(ix)<=2*dy)
% 	datetick('x','dd-HH','keeplimits');
% 	xlabel('Day-Hour (UTC)');
% else
% 	datetick('x','mm/dd','keeplimits');
% 	xlabel('Month/Day (UTC)');
% end
% ylabel('Depth (m)');
% ylim([-93 0]);
% % title('Upcast AOPE-based Dissipation');
% grid on;
% hold on;
% scatter3(mixt(:),mixd(:),-mixd(:),64,[0 0 0],'.');
% 
% cb19=colorbar('TickLabels',emin:(emax-emin)/10:emax,'Ticks',0:.1:1); 
% cb19.Label.String='Log10(epsilon)';
% cb19.TickDirection='both';
% colormap(cb19,cmap18);
% drawnow;
% %%
% if(ocnt < 100)
% 	cntover = cntover(1:ocnt-1);
% 	timover = timover(1:ocnt-1);
% 	Lthorpe = Lthorpe(1:ocnt-1);
% 	Lthoraw = Lthoraw(1:ocnt-1);
% 	Lover = Lover(1:ocnt-1);
% 	Tover = Tover(1:ocnt-1);
% 	Sover = Sover(1:ocnt-1);
% 	rhorms = rhorms(1:ocnt-1);
% 	Nover = Nover(1:ocnt-1);
% 	Neqvover = Neqvover(1:ocnt-1);
% 	Napeover = Napeover(1:ocnt-1);
% 	drdzover = drdzover(1:ocnt-1);
% 	mrawover = mrawover(1:ocnt-1);
% 	msortover = msortover(1:ocnt-1);
% 	topover = topover(1:ocnt-1);
% 	apeover = apeover(1:ocnt-1);
% 	epsA = epsA(1:ocnt-1);
% 	epsTh = epsTh(1:ocnt-1);
% end
% mean(epsTh)/mean(epsA)
% 
% save overstats28 cntover timover Lthorpe Lthoraw Lover Tover Sover rhorms Nover...
% 	Neqvover Napeover drdzover topover apeover epsA epsTh mrawover msortover
% 
% toc; 