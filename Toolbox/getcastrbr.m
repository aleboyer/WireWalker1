function [up,down,dataup,datadown] = getcastrbr(data,crit)

% extract upcast downcast.
% we filt pressure, and find positive and negative chuncks of the pressure
% derivative. Then we iteratively select casts with deltaP (difference between min and max pressure)
% higher the crit (define by user).

% input:
%   data: CTD structure loaded from CTD=load('ctd_deployement.mat'); 
%         It should contain CTD.ctdtime,CTD.P,CTD.T,CTD.S
%   crit: minimal depth from where the profiles will starts.
% output: 
%   up:       upcasts indexes from the ctd
%   down:     downcasts indexes from the ctd
%   dataup:   data (P,S,T,C,sig,ctdtime) for the upcasts
%   datadown: data (P,S,T,C,sig,ctdtime) for the downcasts

%  Created by Arnaud Le Boyer on 7/28/18.


% rename variable to make it easy, only for epsiWW
if isfield(data,'info')
    info=data.info;
    data=rmfield(data,'info');
end
pdata=-data.P;
tdata=data.time;
L=length(tdata);

% buid a filter 
dt=median(diff(tdata)); % sampling period
T=tdata(end)-tdata(1);  % length of the record
speed=diff(pdata(:))./diff(tdata(:))/86400 ;
speed(isnan(speed))=0;


disp('check if time series is shorter than 3 hours')
if T<3/24  
    warning('time serie is less than 3 hours, very short for data processing, watch out the results')
end


disp('smooth the pressure to define up and down cast')
Nb  = 3; % filter order
fnb = 1/(2*dt); % Nyquist frequency
fc  = 1/50/dt; % 50 dt (give "large scale patern") 
[b,a]= butter(Nb,fc/fnb,'low');
filt_speed=filtfilt(b,a,speed);
prime_data=filt_speed;

%Start_ind    =  find(filt_pdata<=-5,1,'first');
Start_ind    =  find(filt_speed<=-crit,1,'first');
nb_down   =  1;
nb_up     =  1;
do_it        =  0;
cast         = 'down';  

while (do_it==0)
    switch cast
        case 'down'
            End_ind=Start_ind+find(prime_data(Start_ind+1:end)>-crit,1,'first');
            if ~isempty(End_ind)
%                deltaP=abs(filt_pdata(Start_ind)-filt_pdata(End_ind));
%                if deltaP>crit
%                     down{nb_down}=Start_ind:End_ind;
%                     nb_down=nb_down+1;
%                end
                down{nb_down}=Start_ind:End_ind;
                nb_down=nb_down+1;
                Start_ind=End_ind+find(prime_data(End_ind+1:end)>crit,1,'first');
                cast='up';
            else
                do_it=1;
            end
        case 'up'
%            End_ind=Start_ind+find(prime_data(Start_ind+1:end)<0,1,'first');
            End_ind=Start_ind+find(prime_data(Start_ind+1:end)<crit,1,'first');
            if ~isempty(End_ind)
%                 deltaP=abs(filt_pdata(Start_ind)-filt_pdata(End_ind));
%                 if deltaP>crit
%                     up{nb_up}=Start_ind:End_ind;
%                     nb_up=nb_up+1;
%                 end
                up{nb_up}=Start_ind:End_ind;
                nb_up=nb_up+1;
                Start_ind=End_ind+find(prime_data(End_ind+1:end)<-crit,1,'first');
                %Start_ind=End_ind;
                cast='down';
            else
                do_it=1;
            end
    end
    if mod(nb_up,10)==0
        fprintf('Upcast %i\n',nb_up)
        fprintf('Downcast %i \n',nb_up)
    end
end

dataup=cellfun(@(x) structfun(@(y) y(x),data,'un',0),up,'un',0);
datadown=cellfun(@(x) structfun(@(y) y(x),data,'un',0),down,'un',0);



for i=1:length(dataup)
    dataup{i}.info=info;
end
for i=1:length(datadown)
    datadown{i}.info=info;
end
 
end
