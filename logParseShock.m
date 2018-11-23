function [onsets]=logParseShock(logFile)
% парсит логфайл для сессий страха
% выдает массив структур onsets. у каждой структуры есть поля type (fig1,
% fig2..), time и dur. Все в секундах. У последнего блока длительно
% выставляется равной 10 сек.
fid = fopen(logFile);
start=0;
prev=0;
X=struct();
for i=1:6
X(i).time=[];
X(i).dur=[];
end
X(1).type='fig1';
X(2).type='fig2';
X(3).type='fig3';
X(4).type='fig1rest';
X(5).type='fig2rest';
X(6).type='fig3rest';
current=0;
while(true)
tline=fgets(fid);
if(tline==-1)
break;
end
currLine=strsplit(tline);
if strcmp(currLine{1},'Event')
start=1;
end
if start
switch currLine{2}
    case 'StartFMRIPulse'
        prev=str2double(currLine{4});
    case 'fig1'
        X(1).time=cat(2,X(1).time,round((str2double(currLine{4})-prev)/10000));
        X(1).dur=cat(2,X(1).dur,round(str2double(currLine{6})/10000)+1);
        current=1;
    case 'fig2'
        X(2).time=cat(2,X(2).time,round((str2double(currLine{4})-prev)/10000));
        X(2).dur=cat(2,X(2).dur,round(str2double(currLine{6})/10000)+1);
        current=2;
    case 'fig3'
        X(3).time=cat(2,X(3).time,round((str2double(currLine{4})-prev)/10000));
        X(3).dur=cat(2,X(3).dur,round(str2double(currLine{6})/10000)+1);
        current=3;
    case 'fig1rest'
        X(4).time=cat(2,X(4).time,round((str2double(currLine{4})-prev)/10000)+1);
        X(4).dur=cat(2,X(4).dur,round(str2double(currLine{6})/10000)-1);
        current=4;
    case 'fig2rest'
        X(5).time=cat(2,X(5).time,round((str2double(currLine{4})-prev)/10000)+1);
        X(5).dur=cat(2,X(5).dur,round(str2double(currLine{6})/10000)-1);
        current=5;
    case 'fig3rest'
        X(6).time=cat(2,X(6).time,round((str2double(currLine{4})-prev)/10000)+1);
        X(6).dur=cat(2,X(6).dur,round(str2double(currLine{6})/10000)-1);
        current=6;
end
end
end
try
X(current).dur(end)=10;
catch
    disp('sdf');
end
fclose(fid);
onsets=X;
end