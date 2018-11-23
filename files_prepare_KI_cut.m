function [ dirs_complete ] = files_prepare_KI_cut(path, FMprefix,fmriPrefix,anatPrefix,TR,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if path(length(path))~='\'
    path=cat(2,path,'\');
end
cd(path);
if ~isempty(varargin)
    cut_mode=1;
    sesNumber=varargin{1};
if length(num2str(sesNumber))==2
    sesStringNumber=strcat('00',num2str(sesNumber));
else
    sesStringNumber=strcat('000',num2str(sesNumber));
end
else
cut_mode=0;
end
D=dir;
analysnm='regress';
n=0;
Nm_str={};
Nm_func={};
z=0;
notPrep=1;
phase=1;
for i=1:length(D)
    if strcmp(D(i).name,'..')||strcmp(D(i).name,'.')
        continue;
    end
    n=n+1;
    q=0;
    w=0;
    Din={};
    Dnm={};
    if D(i).isdir==1
        try
        cd(D(i).name);
        catch
            disp(D(i).name);
        end
        Din=dir;
        for k=1:length(Din)
            Dnm{k}=Din(k).name;
        end
            z=z+1;
            Dir{z}=D(i).name;
            disp(sprintf('Processing session %s',Dir{z}));
            fmriDir=dir(strcat(fmriPrefix,'*'));
                if length(fmriDir)>1
                disp('fmriPrefix satisfies two or more directories');
                cd(path);
                continue;
                elseif isempty(fmriDir)||(~fmriDir.isdir)
                    cd(path);
                        continue;
                end
            if (any(strcmp(Dnm,fmriDir.name)))
            cd(fmriDir.name);
            if ~isempty(dir('f*'));
                disp('preprocessing already done. choose another fmri directory');
                cd(path);
                continue;
            end
            cd ..;
            end
                if cut_mode
                anatDir=dir(strcat(anatPrefix,'*',sesStringNumber));     
                else
                anatDir=dir(strcat(anatPrefix,'*')); 
                end
                if isempty(anatDir)
                    disp('directory with anatomy files not found');
                    cd(path);
                    continue;
                end
                if ~cut_mode
                fmriNum=str2double(fmriDir.name(end-3:end));
                for aN=1:size(anatDir)
                anatNum=str2double(anatDir(aN).name(end-3:end));
                    if fmriNum-anatNum==1
                        correctAnatDir=aN;
                    end
                end
                if length(anatDir)>1
                    anatDir=anatDir(correctAnatDir);
                end
                end
                cd(anatDir.name);
                if ~isempty(dir('wms*.img'))
                    cut_mode=1;
                    disp('working with already preprocessed anatomy files');
                end
                cd ..;
                funcnm=fmriDir.name;
                structnm=anatDir.name;
                mkdir(analysnm);
          notPrep=1;
          cd(funcnm);
          scans=dir('*.ima');
          scanCell=struct2cell(scans);
          Nm_func=scanCell(1,:);
          clear scans scanCell
          cd(strcat('..\',structnm));
          if cut_mode
              strImgRaw=dir('s*.img');
              defFields=dir('y_s*');
          else
          scans=dir('*.ima');

          scanCell=struct2cell(scans);
          Nm_str=scanCell(1,:);
          clear scans scanCell
          end
          cd ..;
          GRE_FM=dir(strcat(FMprefix,'*'));
          if length(GRE_FM)<2
              disp('No field mapping');
              cd(path);
              continue;
          end
          cd(GRE_FM(1).name);
          scans=dir('*.ima');
          scanCell=struct2cell(scans);
          cd(strcat('../',GRE_FM(2).name));
          scans2=dir('*.ima');
          scanCell2=struct2cell(scans2);
          if length(scanCell2(1,:))==2*length(scanCell(1,:))
              phase=1;
              Nm_phase=scanCell(1,:);
              Nm_magn=scanCell2(1,:);
          elseif length(scanCell(1,:))==2*length(scanCell2(1,:))
              phase=2;
              Nm_phase=scanCell2(1,:);
              Nm_magn=scanCell(1,:);
          else 
              disp('different number of slices in magnitude and phase data');
          end
          clear scans scanCell scans2 scanCell2;
          cd ..;
cd(path);
if exist('Nm_str','var')&&exist('Nm_func','var')
if (~isempty(Nm_func))
    if cut_mode
preproc_KI_cut_job;
inputs{1} = Nm_phase; % DICOM Import: DICOM files - cfg_files
    inputs{2} = {strcat(path,'\',D(i).name,'\',GRE_FM(phase).name)}; % DICOM Import: Output directory - cfg_files
    inputs{3} = Nm_magn; % DICOM Import: DICOM files - cfg_files
    inputs{4} = {strcat(path,'\',D(i).name,'\',GRE_FM((phase)-(-1)^(phase)).name)}; % DICOM Import: Output directory - cfg_files
    inputs{5} = Nm_func; % DICOM Import: DICOM files - cfg_files
    inputs{6} = {strcat(path,'\',D(i).name,'\',funcnm)}; % DICOM Import: Output directory - cfg_files
    inputs{7} = {strcat(path,'\',D(i).name,'\',structnm,'\',strImgRaw.name)}; % Presubtracted Phase and Magnitude Data: Select anatomical image for comparison - cfg_files
    inputs{8} = {strcat(path,'\',D(i).name,'\',structnm,'\',strImgRaw.name)}; % Coregister: Estimate: Source Image - cfg_files
    inputs{9} = {strcat(path,'\',D(i).name,'\',structnm,'\',defFields.name)}; % Deformations: Deformation Field - cfg_files
    spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', inputs{:});
cut_mode=0;
    elseif ~cut_mode&&(~isempty(Nm_str))
preproc_KI_job;
for u=1:6
    matlabbatch{9}.spm.tools.preproc8.tissue(u).tpm={sprintf('%s%s,%i',spm('Dir'),'\toolbox\Seg\TPM.nii',u)};        
end
    inputs{1} = Nm_phase; % DICOM Import: DICOM files - cfg_files
    inputs{2} = {strcat(path,'\',D(i).name,'\',GRE_FM(phase).name)}; % DICOM Import: Output directory - cfg_files
    inputs{3} = Nm_magn; % DICOM Import: DICOM files - cfg_files
    inputs{4} = {strcat(path,'\',D(i).name,'\',GRE_FM((phase)-(-1)^(phase)).name)}; % DICOM Import: Output directory - cfg_files
    inputs{5} = Nm_func; % DICOM Import: DICOM files - cfg_files
    inputs{6} = {strcat(path,'\',D(i).name,'\',funcnm)}; % DICOM Import: Output directory - cfg_files
    inputs{7} = Nm_str; % DICOM Import: DICOM files - cfg_files
    inputs{8} = {strcat(path,'\',D(i).name,'\',structnm)}; % DICOM Import: Output directory - cfg_files
spm('defaults', 'FMRI');
save('model','matlabbatch');
spm_jobman('serial', matlabbatch, '', inputs{:});
    end
    % После проведения анализа удаляет промежуточные файлы wurf и rf.
    % Первые - после преобразования в MNI, но еще не сглажены - поэтому
    % нигде не используются
    % Вторые в индивидуальном пространстве после realignment, но до field
    % mapping. 
    cd(D(i).name);
    cd(funcnm);
    wurf=dir('wurf*');
    rf=dir('rf*');
    for ri=1:size(wurf)
        delete(strcat(path,'\',D(i).name,'\',funcnm,'\',wurf(ri).name));
        delete(strcat(path,'\',D(i).name,'\',funcnm,'\',rf(ri).name));
    end
    cd ..;
    delete(analysnm);
cd(path);
end
cd(path);
end
cd(path);
clear Nm_str;
clear Nm_func; 
    end
    cd(path);
end
dirs_complete=Dir;
end

