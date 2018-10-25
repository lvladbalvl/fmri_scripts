function [ matlabbatch ] = compose_paired_ttest( analyDir,dir1,dir2 )
%проводит парный тест между двумя наборами изображений из dir1 и dir2
%Предполагается, что изображений равное кол-во, название представляет собой
%набор имен раздененных подчеркиванием. например
%iFC_Ivanov_1st_day_after_shock.nii. При этом фамилия должна быть второй,
%как в примере и фамилии у файлов из разных папок должны совпадать
%analyDir - директория, куда сохранять файлы анализа
mkdir(analyDir);
cd(dir1);
D1=cat(1,dir('*.nii'),dir('*.img'));
cd(dir2);
D2=cat(1,dir('*.nii'),dir('*.img'));
batch_paired_t_test_job
for i=1:length(D1)
nameCell=strsplit(D1(i).name,'_');
name1{i}=lower(nameCell{2});
end
for i=1:length(D2)
nameCell=strsplit(D2(i).name,'_');
name2{i}=lower(nameCell{2});
end
if length(name2)~=length(name1)
    error('different number of images');
end
for i=1:length(name1)
    s=strfind(name2,name1{i});

    for k=1:length(s)
        if s{k}==1
            matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(i).scans={strcat(dir1,'\',D1(i).name),strcat(dir2,'\',D2(k).name)};
        end
    end
end
matlabbatch{1}.spm.stats.factorial_design.dir={analyDir};
save('model_paired','matlabbatch');
spm_jobman('serial', matlabbatch, '', {});
end

