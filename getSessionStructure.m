function [sessionStructure] = getSessionStructure(pathn)
%выдает листинг директорий в сессиях людей.
%Подходит для данных курчатника в основном. 
% Через writetable(struct2table(sessionStructure), 'someexcelfile.xlsx')
% можно все это впихнуть в excel file. Если с экселем не прокатывает то в
% csv
sessionStructure=struct;
cd(pathn);
D=dir;
z1=0;
for z=1:length(D)
    if strcmp(D(z).name,'..')||strcmp(D(z).name,'.')||~D(z).isdir
            disp(strcat("Skipped ",D(z).name));
            continue;
    end
    cd(D(z).name);
    hcl=dir('HEAD_CLINICAL*');
    if isempty(hcl)
        cd(pathn)
        disp(strcat("Skipped ",D(z).name));
        continue;
    end
    if length(hcl)>1
        cd(pathn)
        disp(strcat("More than one HEAD_CLINICAL... in ",D(z).name));
        continue;
    end
    %cd(hcl.name);
    Din=dir;
    z1=z1+1;
    sessionStructure(z1).session=D(z).name;
    for i=1:length(Din)
        if ~strcmp(Din(i).name,'..')&&~strcmp(Din(i).name,'.')&&Din(i).isdir
            if ~isfield(sessionStructure,strrep(Din(i).name(1:end-5),'+','_'))||(isempty(eval(strrep(strcat('sessionStructure(z1).',Din(i).name(1:end-5)),'+','_'))))
                try
                eval(strrep(strcat('sessionStructure(z1).',Din(i).name(1:end-5),'=1'),'+','_'))
                catch
                disp('sdf')    
                end
            else
                eval(strcat(strrep(strcat('sessionStructure(z1).',Din(i).name(1:end-5),'=','sessionStructure(z1).',Din(i).name(1:end-5)),'+','_'),'+1'))
            end
        end
    end
    cd(pathn);
end

