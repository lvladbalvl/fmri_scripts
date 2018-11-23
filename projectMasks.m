function [] = projectMasks(pathn,FMprefix,AnatPrefixFull,maskdir)
%проецирует маски в индивидуальное пространство испытуемых из pathn
%Делает то же самое, что и в ROI_CC_wfu, но только проецирует маски, а
%дальше ничего не рассчитывает. Если использовать его, а потом ROI_CC_wfu,
%то можно проецировать маски через среднее фМРТ в этом скрипте, а потом
%запускать ROI_CC_wfu - он будет видеть, что маски уже есть и сразу
%переходить к расчетам корреляций.
% Важно: если скрипт прерван, то надо проверить maskdir и удалить файлы с
% префиксом rmask. Они удаляются сами, если скрипт работает, но если комп
% выключился или вы просто решили все прервать - нужно удалять вручную.
% Иначе они воспримутся как обычные маски (хотя это просто изображения
% интерполированное на размер вокселя 1.5х1.5х1.5)
cd(maskdir);
indFuncPrefix='ResI';
maskFiles=cat(1,dir('*.nii'),dir('*.img'));
p=length(maskFiles);
z1=0;
for u=1:p
    maskFilesAbsPath{u}=strcat(maskdir,'\',maskFiles(u).name);
end
cd(pathn)
D=dir;
AnatPrefix=AnatPrefixFull{1};
for z=1:length(D)
    if strcmp(D(z).name,'..')||strcmp(D(z).name,'.')||~D(z).isdir
            disp(strcat('Skipped',D(z).name));
            continue;
    end
        cd(D(z).name);
        findAnat=0;
        Din=dir;
        for j=1:length(Din)
            Dnm{j}=Din(j).name;
        end
        fmriDir=dir(strcat(FMprefix,'*'));
        anatDir=dir(strcat(AnatPrefix,'*'));
        if isempty(fmriDir)
            cd(pathn{pn});
            continue;
        end
        if isempty(anatDir)
            for k=2:length(AnatPrefixFull)
                anatDir=dir(strcat(AnatPrefixFull{k},'*'));
                if ~isempty(anatDir)
                    findAnat=1;
                end
            end
            if ~findAnat
                disp("Anatomy not found")
                cd(pathn{pn});
                continue;
            end
        end
                funcnm=fmriDir.name;
                structnm=anatDir.name;
        if (~any(strcmp(Dnm,funcnm)))||(~any(strcmp(Dnm,structnm)))
            cd(pathn{pn});
            disp("Can not find anatomy and/or functional dir")
            continue;
        end
        disp(strcat('Working with ',D(z).name));
        z1=z1+1;
cd(funcnm);
FuncImg=cat(1,dir(strcat(indFuncPrefix,'*.nii')),dir(strcat(indFuncPrefix,'*.img')));
cd ..;
cd(structnm);
RLabelFile=cat(1,dir('rwrmask*.nii'),dir('rwrmask*.img'));
checkedMasks=zeros(1,length(RLabelFile));
for l=1:length(RLabelFile)
    for l1=1:length(maskFiles)
        if strcmp(RLabelFile(l).name,strcat('rwrmask',maskFiles(l1).name))
            checkedMasks(l)=1;
        end
    end
end
RLabelFile(find(checkedMasks==0))=[];
if length(RLabelFile)<p
    for l=1:p
        wfu_to_individ_job;
        wmsFile=dir('wms*.nii');
        matlabbatch{1}.spm.spatial.coreg.write.ref={wmsFile.name};
        matlabbatch{1}.spm.spatial.coreg.write.source=maskFilesAbsPath(l);
        inverseDefFile=dir('iy_s*.nii');
        matlabbatch{2}.spm.util.defs.comp{1}.def={inverseDefFile.name};
        matlabbatch{2}.spm.util.defs.savedir.saveusr={strcat(pathn,'\',D(z).name,'\',structnm)};
        matlabbatch{3}.spm.spatial.coreg.write.ref={strcat(pathn,'\',D(z).name,'\',funcnm,'\',FuncImg(1).name)};
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch, '', '');
        clear matlabbatch;
    end
            masksNew=cat(1,dir(strcat(maskdir,'\rmask*.nii')),dir(strcat(maskdir,'\rmask*.img')));
        for k=1:length(masksNew)
            delete(strcat(maskdir,'\',masksNew(k).name));
        end
end
    cd(pathn);
end
end

