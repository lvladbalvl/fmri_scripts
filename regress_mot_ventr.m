function [ ] = regress_mot_ventr( pathn,FMprefix,AnatPrefix,mask,TR )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
p=1;
If=[];
cd(pathn);
filtflag=0;
%[B,A]=butter(3,[0.01*2*TR 0.1*2*TR]);
dt=2;
z1=0;
D=dir;
V=struct;
for z=3:length(D)
    if isdir(D(z).name)
        cd(D(z).name);
        Din=dir;
        for k=1:length(Din)
            Dnm{k}=Din(k).name;
        end
        fmriDir=dir(strcat(FMprefix,'*'));
        anatDir=dir(strcat(AnatPrefix,'*'));
        if isempty(fmriDir)
            cd(pathn);
            continue;
        end
                funcnm=fmriDir.name;
                structnm=anatDir.name;
        if (~any(strcmp(Dnm,funcnm)))||(~any(strcmp(Dnm,structnm)))
            cd(pathn);
            continue;
        end
        disp(strcat('Working with ',D(z).name));
        z1=z1+1;
        try
cd(funcnm);
        catch
            break;
        end
FuncImg=dir('urf*.img');
if isempty(FuncImg)
    disp('no urf files');
end
if ~isempty(V)
    clear V;
end
V(1)=spm_vol(FuncImg(1).name);
cd ..;
if ~isempty(dir('regrindspace'))
    disp('already processed. Skipped');
    %rmdir('regress','s');
    cd(pathn);
    continue;
end
mkdir('regrindspace');
cd(structnm);
StructFile=dir('s*.img');
if length(StructFile)>1
StructFile=StructFile(1);
end
        wfu_to_individ_job;
        wmsFile=dir('wms*.nii');
        matlabbatch{1}.spm.spatial.coreg.write.ref={wmsFile.name};
        matlabbatch{1}.spm.spatial.coreg.write.source={mask};
        inverseDefFile=dir('iy_s*.nii');
        matlabbatch{2}.spm.util.defs.comp{1}.def={inverseDefFile.name};
        matlabbatch{2}.spm.util.defs.savedir.saveusr={strcat(pathn,'\',D(z).name,'\',structnm)};
        matlabbatch{3}.spm.spatial.coreg.write.ref={strcat(pathn,'\',D(z).name,'\',funcnm,'\',FuncImg(1).name)};
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch, '', '');
        clear matlabbatch;
Imask=spm_read_vols(spm_vol('rwrmaskventricles.nii'));
cd ..;
cd(funcnm);
rpTxt=dir('*.txt');
RFuncImg=dir('urf*.img');
swurf=dir('urf*.img');
swurfCell=struct2cell(swurf);
swurfNames=swurfCell(1,:);
if ~isempty(If)
    clear If
end
[NZE1,NZE2,NZE3]=ind2sub(size(Imask),find(Imask));
for i=1:length(RFuncImg)
Vc=spm_vol(RFuncImg(i).name);
Iven(i)=mean(spm_sample_vol(Vc,NZE1,NZE2,NZE3,1));
end
%Iven=squeeze(mean(mean(mean(If,3),2),1));
for i=1:length(swurfNames)
swurfNames(i)={strcat(pathn,'\',D(z).name,'\',funcnm,'\',swurfNames{i})};
end
regressout_job;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg={strcat(pathn,'\',D(z).name,'\',funcnm,'\',rpTxt.name)};
    inputs{1} = {strcat(pathn,'\',D(z).name,'\regrindspace')}; % fMRI model specification: Directory - cfg_files
    inputs{2} = TR; % fMRI model specification: Interscan interval - cfg_entry
    inputs{3} = swurfNames; % fMRI model specification: Scans - cfg_files
    inputs{4} = 'Ventricles Signal'; % fMRI model specification: Name - cfg_entry
    inputs{5} = Iven; % fMRI model specification: Value - cfg_entry
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', inputs{:});
clear matlabbatch;
    end
    cd(pathn);
    end
end
