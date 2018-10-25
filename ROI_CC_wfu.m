function [ CC] = ROI_CC_wfu( pathn,FMprefix,AnatPrefixFull, maskdir,TR,contin )
%Считает коэффициенты корреляции между сигналами из масок из maskdir
%Пробегается по всем людям (при этом можно задавать сразу несколько абсолютных путей в pathn через переменную типа cell. например
%{'F:\Fear\',''E:\Fear2\'}, проверяет наличие нужных файлов в фмрт
%директории с префиксом FMprefix и директории со структурками
%AnatPrefixFull (при этом FMprefix - просто префикс в одинарных кавычках, а
%AnatPrefixFull - переменная типа cell, то есть массив строковых
%переменных, которая в порядке возрастания приоритетат смотрит все
%перечисленные структурный папки. Например {'T1...0007', 'T1....0002'}. Для
%каждого человека предполагается, что данные лежат в папке 0007, но если
%кто-то накосячил и у какого-то конкретного человека нет папки 0007, а
%тольк опапка 0002, то у него данные возьмутся из 0002
% Перед расчетом коэффициентов корреляции данные фильтруются если
% filtflag=1. Если filtflag=0, то фильтроваться не будут. Берется полосовой фильтр
% баттерворта 5 степени с границами в 0.01 и 0.1 Гц. 
% Теоретически можно продолжать прерванный расчет задавая переменную contin=1, но это
% не доделано. В противном случае каждый раз расчет запускается заново
% И для pathn и для AnatPrefixFull - даже если вариант только один все
% равно нужно задавать в фигурных скобках. ну и в одинарных кавычках как и
% везде
% Важно: если скрипт прерван, то надо проверить maskdir и удалить файлы с
% префиксом rmask. Они удаляются сами, если скрипт работает, но если комп
% выключился или вы просто решили все прервать - нужно удалять вручную.
% Иначе они воспримутся как обычные маски (хотя это просто изображения
% интерполированное на размер вокселя 1.5х1.5х1.5
filtflag=1;
[B,A]=butter(5,[0.01*2*TR 0.1*2*TR]);
% префикс фМРТ файла нужно задать. Как правило расчет идет для файлов
% отрегрессированных. Поэтому префикс ResI (residual images выплевываются
% spm'ом)
funcImgPrefix='ResI';
cd(maskdir);
 if contin
        CC1=load('E:\CC_cur');
        CC2=CC1.CC;
        z1=length(CC2);
        CC(1:z1)=CC2;
 else
        z1=0;
 end
%сначала добывает список всех масок и абсолютные пути к ним
maskFiles=cat(1,dir('*.nii'),dir('*.img'));
If=[];
AnatPrefix=AnatPrefixFull{1};
p=length(maskFiles);
for u=1:p
    maskFilesAbsPath{u}=strcat(maskdir,'\',maskFiles(u).name);
end


for pn=1:length(pathn)
cd(pathn{pn});


%[B2, A2]=butter(5,0.01,'high');
dt=2;

D=dir;
for z=1:length(D)
    if strcmp(D(z).name,'..')||strcmp(D(z).name,'.')||~D(z).isdir
            disp(strcat('Skipped',D(z).name));
            continue;
    end
        skipDir=0;
        if contin
                for g=1:length(CC2)
                    if strcmp(CC2(g).session,D(z).name)
                        skipDir=1;
                        break;
                    end
                end
                if skipDir
                    continue;
                end
        end
        cd(D(z).name);

        Din=dir;
        for k=1:length(Din)
            Dnm{k}=Din(k).name;
        end
        findAnat=0;
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
                cd(pathn{pn});
                continue;
            end
        end
                funcnm=fmriDir.name;
                structnm=anatDir.name;
        if (~any(strcmp(Dnm,funcnm)))||(~any(strcmp(Dnm,structnm)))
            cd(pathn{pn});
            continue;
        end
        disp(strcat('Working with ',D(z).name));
        z1=z1+1;
        try
cd(funcnm);
        catch
            break;
        end
FuncImg=dir(strcat(funcImgPrefix,'*.img'));
V(1)=spm_vol(FuncImg(1).name);
cd ..;
cd(structnm);
StructFile=dir('s*.img');
if length(StructFile)>1
StructFile=StructFile(1);
end
StructVol=spm_vol(StructFile.name);
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
%здесь можно врубить если нужно чтобы все маски с предыдущих анализов
%сносились. Но важно понимать что маска желудочков например тоже снесется
%temporary part
% for rl=length(RLabelFile):-1:1
%     delete(RLabelFile(rl).name);
%     RLabelFile(rl)=[];
% end
%temporary part
% если не все маски обработаны то обрабатываем все заново (в рамках одного
% человека естественно) далее кусок с циклом по всем маскам и
% coregistration-deformation-coregistration до фМРТ в
% индвивидуальном пространстве. Если хотим до среднего фМРТ - нужно
% немножко переписать и еще шерстить папку с фМРТ изображениями, а не
% только с ResI и оттуда доставить meanf или umeanf (если сделан field
% mapping) и передавать в matlabbatch{3}.spm.spatial.coreg.write.ref
% (десятью строками ниже)
if length(RLabelFile)<p
    for l=1:p
        wfu_to_individ_job;
        wmsFile=dir('wms*.nii');
        matlabbatch{1}.spm.spatial.coreg.write.ref={wmsFile.name};
        matlabbatch{1}.spm.spatial.coreg.write.source=maskFilesAbsPath(l);
        inverseDefFile=dir('iy_s*.nii');
        matlabbatch{2}.spm.util.defs.comp{1}.def={inverseDefFile.name};
        matlabbatch{2}.spm.util.defs.savedir.saveusr={strcat(pathn{pn},'\',D(z).name,'\',structnm)};
        matlabbatch{3}.spm.spatial.coreg.write.ref={strcat(pathn{pn},'\',D(z).name,'\',funcnm,'\',FuncImg(1).name)};
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch, '', '');
        clear matlabbatch;
    end
            masksNew=cat(1,dir(strcat(maskdir,'\rmask*.nii')),dir(strcat(maskdir,'\rmask*.img')));
        for k=1:length(masksNew)
            delete(strcat(maskdir,'\',masksNew(k).name));
        end
end
RLabelFile=cat(1,dir('rwrmask*.nii'),dir('rwrmask*.img'));
checkedMasks=zeros(1,length(RLabelFile));
%составляет список тех масок, которые были заявлены и сделаны, чтобы
%удалить только их потом
for l=1:length(RLabelFile)
    for l1=1:length(maskFiles)
        if strcmp(RLabelFile(l).name,strcat('rwrmask',maskFiles(l1).name))
            checkedMasks(l)=1;
        end
    end
end
RLabelFile(find(checkedMasks==0))=[];
cd ..;
cd(funcnm);
RFuncImg=dir(strcat(funcImgPrefix,'*.img'));
if ~isempty(If)
    clear If
end
%загружает все хедеры фМРТ данных человека в память
for i=1:length(RFuncImg)
    Vc(i)=spm_vol(RFuncImg(i).name);
end
CC(z1).session=D(z).name;
k=0;
qq=0;
mat=[];
%начинает два цикла. Первый по всем индексам до числа масок минус один, а
%второй цикл соответственно от второго индекса и до числа масок. Тут
%большая возня с индеками была организована, поскольку изанчально был
%реализован еще сдвиг от -dt до +dt сигналов относительно друг друга, все
%это записывалось в CC со своим индексом, а потом уже брался максимум
%в основном важен индекс qq - который просто задает номер пары, хотя его
%можно было бы просто инкрементить когда пишем значение CC для пары
% Важно: Все NaN воксели в масках - не учитываются. Соответственно тут два
% результата: 1) могут быть маски где только несколько вокселей например из
% 1000 не NaN - она возьмется и будет браться сигнал только из нескольких
% этих вокселей. 2) могут быть маски где все воксели NaN - у нее будет
% сигнал = 0 для всех отсчетов времени, а корреляция даст NaN
for k1=1:p-1
    k=k+1;
    j=k;
    mask1Path=strcat(pathn{pn},'\',D(z).name,'\',structnm,'\',RLabelFile(k).name);
    Imask1=spm_read_vols(spm_vol(mask1Path));
    [NZE1,NZE2,NZE3]=ind2sub(size(Imask1),find(Imask1));
    If1=zeros(length(RFuncImg),1);
    for v=1:length(RFuncImg)
        Ifc=spm_sample_vol(Vc(v),NZE1,NZE2,NZE3,1);
        Ifc(isnan(Ifc))=0;
        If1(v)=mean(Ifc);
    end
    if filtflag
    Tc1=filtfilt(B,A,If1);
    %Tc1=filtfilt(B2,A2,Tc1);
    else
    Tc1=squeeze(mean(mean(mean(If.*Imask1,3),2),1));    
    end
    for j1=(k+1):p
        qq=qq+1;
        j=j+1;
        mask2Path=strcat(pathn{pn},'\',D(z).name,'\',structnm,'\',RLabelFile(j).name);
        Imask2=spm_read_vols(spm_vol(mask2Path));
        clear NZE1 NZE2 NZE3
        [NZE1,NZE2,NZE3]=ind2sub(size(Imask2),find(Imask2));
        If2=zeros(length(RFuncImg),1);
        for v=1:length(RFuncImg)
            Ifc=spm_sample_vol(Vc(v),NZE1,NZE2,NZE3,1);
            Ifc(isnan(Ifc))=0;
            If2(v)=mean(Ifc);
        end
        
        if filtflag
        Tc2=filtfilt(B,A,If2);
        %Tc2=filtfilt(B2,A2,Tc2);
        else
        Tc2=squeeze(mean(mean(mean(If.*Imask2,3),2),1));    
        end
        maxCC=0;
        CC1=corrcoef(Tc1,Tc2);
            maxCC=CC1(1,2);
        if isnan(maxCC)
        disp('sdf');
        end
        CC(z1).value(qq)=maxCC;
        CC(z1).name{qq}=strcat(RLabelFile(k).name(1:end-4),' - ',RLabelFile(j).name(1:end-4));
        if j==p
            break;
        end
    end
end
    save('E:\CC_cur','CC');
    cd(pathn{pn});
end
end
end
