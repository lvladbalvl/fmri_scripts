function [onsets, dial]=logParse(logFile)
fid = fopen(logFile);
start=0;
prev=0;
X=struct();
Types={ '100eur' '100dol' '5000rub' 'n_banana' 'n_pear' 'n_apple' 'i_floppy_disk' 'i_cd' 'i_video_tape' 'dial'};
questTypes={'100' '110' '120' '130' '140' '150' '160' '170' '180' '190' '102'};
dial=struct();
dial.time=[];
dial.num=[];
for i=1:length(Types)+length(questTypes)-1
X(i).time=[];
X(i).dur=[];
X(i).type='';
end
current=0;
while(true)
tline=fgets(fid);
if(tline==-1)
break;
end
currLine=strsplit(tline);
if length(currLine)>2
    if strcmp(currLine{3},'Pulse')
        start=1;
    end
end
if start
    currCase=find(strcmp(Types,currLine{5}));
    if (strcmp(currLine{4},'StartFMRIPulse'))
       prev=str2double(currLine{5}); 
    elseif (strcmp(currLine{5},'question'))
        currQuest=find(strcmp(questTypes,currLine{4}));
        if currQuest==length(questTypes)
            disp('may be mistake in log file with question number. if 102 instead of 120 - ok')
            currQuest=find(strcmp(questTypes,'120'));
        end
        if (currQuest==3)
            if (current==10)
            currQuest=1;
            end
        end
        if (currQuest==8)
            if current==4
                disp('may be mistake in log file with question number. n_banana followed by question 170. made it 140')
                currQuest=5;
            end
        end
        current=currQuest+length(Types);
        X(current).time=cat(2,X(current).time,round((str2double(currLine{6})-prev)/10000));
        X(current).dur=cat(2,X(current).dur,round(str2double(currLine{9})/10000));
             if (isempty(X(current).type))
                X(current).type=strcat('Question ',questTypes{currQuest});
            end
    elseif isempty(currCase)
        continue;
    else
       X(currCase).time=cat(2,X(currCase).time,round((str2double(currLine{6})-prev)/10000));
            X(currCase).dur=cat(2,X(currCase).dur,round(str2double(currLine{9})/10000));
            current=currCase;
            if (isempty(X(currCase).type))
                X(currCase).type=Types{currCase};
            end
            if currCase==10
                dial.time=cat(2,dial.time,round((str2double(currLine{6})-prev)/10000));
                dial.num=cat(1,dial.num,currLine{4});
            end
    end
end
end
X(current).dur(end)=X(current).dur(end);
fclose(fid);
onsets=X;
end