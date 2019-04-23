function SD=buildepsiWWtime(Meta_Data,a)

% a is the product of San's code for exemple see read_10_files_SODA_WW_d2.m)
% Meta_data is the the meta_data of the deployement
% 

name_channels=strsplit(Meta_Data.PROCESS.channels,',');
nbchannels=str2double(Meta_Data.PROCESS.nb_channels);

starttime=Meta_Data.starttime;
SD.timeheader=a.madre.TimeStamp/86400+datenum(1970,1,1);
SD.timeheader=starttime+(SD.timeheader-SD.timeheader(1));

dtimeheader=diff(SD.timeheader);
SD.epsitime=zeros(1,160*numel(SD.timeheader));
last_t=0;
count=0;
flag_timebug=0;
for t=1:numel(dtimeheader)
    dT=dtimeheader(t);
    if dT==0
        count=count+1;
    end
    if dT>0
        if t==1
            SD.epsitime(1:160)=SD.timeheader(1)-fliplr(linspace(1/325/86400,.5/86400,160));
        else
            if flag_timebug==0 % normal case
                SD.epsitime((last_t+1)*160+1:(t+1)*160)=linspace(SD.timeheader(last_t+1)+1/325/86400,SD.timeheader(t+1),160+count*160);
            else   % if the timestamp bug and are decreasing
                SD.epsitime((last_t+1)*160+1:(t+1)*160)=linspace(SD.timeheader(t+1)-.5/86400,SD.timeheader(t+1),160+count*160);
            end
        end
        last_t=t;
        count=0;
        flag_timebug=0;
    end
    if dT<0
        SD.epsitime((last_t+1)*160:(t+1)*160)=nan;
        last_t=t;
        count=0;
        flag_timebug=1;
        disp(t)
    end
end

if dtimeheader(1)==0
    SD.epsitime(1:160)=SD.epsitime(161) - fliplr(linspace(1/325/86400,.5/86400,160));
end
if dtimeheader(end)==0
    SD.epsitime(end-(160+count*160)+1:end)=SD.timeheader(end)- fliplr(linspace(1/325/86400,(.5+count*.5)/86400,160+count*160));
end

for n=1:nbchannels
    eval(sprintf('SD.%s=a.epsi.%s;',name_channels{n},name_channels{n}));
end


ind_OK=find(SD.epsitime>=SD.epsitime(1) & SD.epsitime<max(SD.epsitime));
SD.epsitime=SD.epsitime(ind_OK);
%epsitime=epsitime-epsitime(1);
for n=1:nbchannels
    eval(sprintf('SD.%s=SD.%s(ind_OK);',name_channels{n},name_channels{n}));
end
SD.flagSDSTR=SD.epsitime*0;


% command=[];
% for n=1:nbchannels
%     command=[command ',' sprintf('''%s''',name_channels{n})];
% end
% command=['''index'',''epsitime'',''flagSDSTR'',''sderror'',''chsum1'',''alti'',''chsumepsi''' command];
% command=sprintf('save(''%sepsi_%s.mat'',%s)',epsiDIR,Meta_Data.deployement,command);
% eval(command);
% disp('stop')
