function [up,down,dataup,datadown] = mod_getcastnortek(Meta_Data,min_depth,crit_depth)


% extract upcast downcast.
% we filt pressure, and find positive and negative chuncks of the pressure
% derivative. Then we iteratively select casts with deltaP (difference between min and max pressure)
% higher the crit (define by user).

% input:
%   data: AQD structure loaded from AQD=load('ctd_deployement.mat'); 
%         It should contain AQD.Burst_Pressure,AQD.Burst_TimeP and all the
%         fields from Signature deployment 
%   crit: minimal depth from where the 1st profiles will start.

% output: 
%   up:       upcasts indexes from the ctd
%   down:     downcasts indexes from the ctd
%   dataup:   data  for the upcasts
%   datadown: data  for the downcasts

%  Created by Arnaud Le Boyer on 7/28/18.
if nargin<2
    crit_depth=10;
    min_depth=3;
end

if nargin<3
    crit_depth=10;
end
load(fullfile(Meta_Data.adcppath,[Meta_Data.name_adcp '.mat']),Meta_Data.name_adcp);
eval(sprintf('data=%s;',Meta_Data.name_adcp));


pdata=double(data.Burst_Pressure);
tdata=data.Burst_Time;
L=length(tdata);

% get time resolution
dt=median(diff(tdata)*86400); % sampling period

% inverse pressure and remove outliers above the std deviation of a sliding window of 20 points
pdata=filloutliers(pdata,'center','movmedian',20);
% buid a filter
disp('smooth the pressure to define up and down cast')
Nb  = 3; % filter order
fnb = 1/(2*dt); % Nyquist frequency
fc  = 1/60/dt; % 50 dt (give "large scale patern") 
[b,a]= butter(Nb,fc/fnb,'low');
% filt fall rate
pdata=filtfilt(b,a,pdata);

T=size(pdata);
disp('check if time series is shorter than 3 hours')
if T<3/24  
    warning('time serie is less than 3 hours, very short for data processing, watch out the results')
end


% we start at the top when the fallrate is higher than the criterium
% and look for the next time the speed is lower than that criteria to end
% the cast.
% we iterate the process to define all the casts
Start_ind    =  find(pdata>=min_depth,1,'first');
nb_down   =  1;
nb_up     =  1;
do_it        =  0;

while (do_it==0)
    End_ind=Start_ind+find(pdata(Start_ind+1:end)<min_depth,1,'first');
    if ~isempty(End_ind)
        down{nb_down}=Start_ind+(1:find(pdata(Start_ind:End_ind)==max(pdata(Start_ind:End_ind))));
        nb_down=nb_down+1;
        up{nb_up}=Start_ind+find(pdata(Start_ind:End_ind)==max(pdata(Start_ind:End_ind)))+1:End_ind;
        nb_up=nb_up+1;
        Start_ind =  End_ind+1+find(pdata(End_ind+1:end)>=min_depth,1,'first');
    else
        do_it=1;
    end
    if mod(nb_up,10)==0
        fprintf('Upcast %i\n',nb_up)
        fprintf('Downcast %i \n',nb_up)
    end
end



%once we have the index defining the casts we split the data
dataup=cellfun(@(x) structfun(@(y) y(x,:),data,'un',0),up,'un',0);
datadown=cellfun(@(x) structfun(@(y) y(x,:),data,'un',0),down,'un',0);


% select only cast with more than 10 points. 10 points is arbitrary
indPup=find(cellfun(@(x) x.Burst_Pressure(1)-x.Burst_Pressure(end),dataup)>crit_depth);
indPdown=find(cellfun(@(x) x.Burst_Pressure(end)-x.Burst_Pressure(1),datadown)>crit_depth);

datadown=datadown(indPdown);
dataup=dataup(indPup);
down=down(indPdown);
up=up(indPup);

% plot pressure and highlight up /down casts in red/green
close all
plot(tdata,pdata)
hold on
for i=1:length(up)
        plot(dataup{i}.Burst_Time,dataup{i}.Burst_Pressure,'r')
end
for i=1:length(down)
       plot(datadown{i}.Burst_Time,datadown{i}.Burst_Pressure,'g')
end

%MHA: plot ocean style
axis ij



end
