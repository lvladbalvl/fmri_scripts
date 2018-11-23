function [ dirs_complete ] = files_prepare_non(path, funcnm, structnm)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if path(length(path))~='\'
    path=cat(2,path,'\');
end
cd(path);
D=dir;
n=0;
Nm_str={};
Nm_func={};
z=0;
for i=3:length(D)
    n=n+1;
    q=0;
    w=0;
    Din={};
    Dnm={};
    if D(i).isdir==1
        cd(D(i).name);
        Din=dir;
        for k=1:length(Din)
            Dnm{k}=Din(k).name;
        end
        %if any(strcmp(Dnm,'ScannerFiles'))&&(~any(strcmp(Dnm,funcnm)))&&(~any(strcmp(Dnm,structnm)))
            if (~any(strcmp(Dnm,funcnm)))&&(~any(strcmp(Dnm,structnm)))
        z=z+1;
            Dir{z}=D(i).name;
            
            disp(sprintf('Processing session %s',Dir{z}));
                            mkdir(funcnm);
                mkdir(structnm);
          %cd ScannerFiles\1\DicomImages;
          Scans=dir('06*');
          for p=1:length(Scans)
              if Scans(p).bytes>180*1024&&Scans(p).bytes<200*1024
                  str1=sprintf('\\%s\\',structnm);
                  str{n}=cat(2,D(i).name,str1);
                  str{n}=cat(2,path,str{n});
                  M=movefile(Scans(p).name,str{n});
                  q=q+1;
                  Nm_str{q}=cat(2,str{n},Scans(p).name);
              end

              if (Scans(p).bytes>200*1024)&&(Scans(p).bytes<500*1024)
                  strf1=sprintf('\\%s\\',funcnm);
                  strf{n}=cat(2,D(i).name,strf1);
                  strf{n}=cat(2,path,strf{n});
                  M=movefile(Scans(p).name,strf{n});
                  w=w+1;
                  Nm_func{w}=cat(2,strf{n},Scans(p).name);                  
              end              
          end
cd(path);
if exist('Nm_str','var')&&exist('Nm_func','var')
if (~isempty(Nm_str))&&(~isempty(Nm_func))
nrun = 1; % enter the number of runs here
prepro_DCM_new_job;
for u=1:6
    if strcmp(spm('version'),'SPM8 (6313)');
    matlabbatch{5}.spm.tools.preproc8.tissue(u).tpm={sprintf('%s%s',spm('Dir'),'\toolbox\Seg\TPM.nii')};        
    else
    matlabbatch{5}.spm.tools.preproc8.tissue(u).tpm={sprintf('%s%s',spm('Dir'),'\tpm\TPM.nii')};
    end
end
inputs = cell(4, nrun);
for crun = 1:nrun
    inputs{1, crun} = Nm_func; % DICOM Import: DICOM files - cfg_files
    inputs{2, crun} = {strf{n}}; % DICOM Import: Output directory - cfg_files
    inputs{3, crun} = Nm_str; % DICOM Import: DICOM files - cfg_files
    inputs{4, crun} = {str{n}}; % DICOM Import: Output directory - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', inputs{:});
end
end
clear Nm_str;
clear Nm_func; 
else
   disp(sprintf('Skipped %s',D(i).name));
   %cd(funcnm);
   %A=dir('*.dcm');
   %for x=1:length(A)
   %B{x}=A(x).name;
   %end
   %zip(strcat('func_',D(i).name,'.zip'),B);
   %clear A B
   %cd ..;
   %   cd(structnm);
   %A=dir('*.dcm');
   %for x=1:length(A)
   %B{x}=A(x).name;
   %end
   %zip(strcat('struct_',D(i).name,'.zip'),B);
   cd(path)
          end
    end
    cd(path);
end
dirs_complete=Dir;
end

