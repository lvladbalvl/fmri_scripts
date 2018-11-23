function [] = copy_con_files( sessDir,conDirName,connum,destDir)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
cd(sessDir);
D=dir;
for i=1:length(D)
    if strcmp(D(i).name,'..')||strcmp(D(i).name,'.')||~D(i).isdir
     disp(strcat('Skipped',D(i).name));
     continue;
    end
    try
    cd(D(i).name);
    catch
    end
    conDir=dir(strcat(conDirName,'*'));
    if isempty(conDir)&&(length(conDir)~=1)
        conDir=dir(strcat(conDirName));
    end
    if isempty(conDir)&&(length(conDir)~=1)    
        cd(sessDir);
        disp('no match for search directory or too many results');
        continue;
    end
    conDir=conDir(1);
    cd(conDir.name);
    conFile=dir(strcat('con_',num2str(connum,'%04.f'),'*'));
    for k=1:length(conFile)
        copyfile(strcat(sessDir,'\',D(i).name,'\',conDir.name,'\',conFile(k).name),strcat(destDir,'\',D(i).name,'_',conFile(k).name));
    end
    cd(sessDir);
end

