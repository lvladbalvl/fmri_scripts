function [ dirs_complete ] = first_level_KI_shock(pathn,fmriPrefix,TR,mask,type,dur)
%анализ первого уровн€ дл€ данных по страху
%  проходит по папкам из pathn, провер€ет в них наличии фћ–“ папки с
%  префиксом fmriPrefix, берет оттуда фћ–“ изображени€ (swurf), текстовый
%  файл с регрессорами движени€. »з папки с испытуемым берет еще файл с
%  дыханием. ѕредполагаетс€, что дыхание €вл€етс€ вторым каналом в ЁЁ√
%  файлах или типа dat или bdf. ¬ случае bdf предполагаетс€, что сессий
%  внутри одного bdf файла несколько, но только одна slow TR (это
%  совершенно не об€зательно - но дл€ данных страха получалось так. в
%  основном попадались файлы где было три сессии, две с быстрым “– и одна
%  нужна€ с медленным)
%  в mask прописан абсолютный путь к файлу с маской желудочков
%  type -  задает по полной сессии считать или по половине (по первой. дл€ второй
%  половины нужно переписывать скрипт. нужные дл€ этого строки есть, но
%  закомментированы)
%  по умолчанию делаетс€ event-related design, но если задать dur, то из
%  лога будет братьс€ и длительность предъ€влений. »значально предполагалось, что
%  будет еще вариант задавать константой длительность предъ€влений -
%  поэтому была введена така€ переменна€, но сейчас только провер€етс€ есть
%  она или нет
if pathn(length(pathn))~='\'
    pathn=cat(2,pathn,'\');
end
cd(pathn);

Imask=spm_read_vols(spm_vol(mask));
D=dir;
analysnm='1st_level_sechalf_breath_new';
n=0;
Nm_str={};
Nm_func={};
z=0;
notPrep=1;
% FMprefix='GRE_FIELD_MAPPING_REST_+E';
% fmriPrefix='REST_DF30_+_E';
% anatPrefix='T1_SAG_3D_ANATOMY_1X1X1_FAST';
phase=1;
for i=3:length(D)
    n=n+1;
    q=0;
    w=0;
    Din={};
    Dnm={};
    if D(i).isdir==1
        cd(D(i).name);
        Din=dir;
        if ~isempty(dir(analysnm))
            cd(pathn);
            disp('already processed');
            continue;
        end
        for k=1:length(Din)
            Dnm{k}=Din(k).name;
        end
            z=z+1;
            Dir{z}=D(i).name;
            disp(sprintf('Processing session %s',Dir{z}));
            fmriDir=dir(strcat(fmriPrefix,'*'));
                if length(fmriDir)>1
                disp('fmriPrefix satisfies two or more directories');
                cd(pathn);
                continue;
                elseif isempty(fmriDir)||(~fmriDir.isdir)
                    cd(pathn);
                    disp('No fmri Dir');
                        continue;
                end
            if (any(strcmp(Dnm,fmriDir.name)))
            cd(fmriDir.name);
            if isempty(dir('swurf*'));
                disp('preprocessing not done yet');
                cd(pathn);
                continue;
            end
            cd ..;
            end
                funcnm=fmriDir.name;
          cd(funcnm);
          swurf=dir('swurf*.img');
          swurfCell=struct2cell(swurf);
          Nm_func=swurfCell(1,:);
          txtFile=dir('rp*.txt');
          
          if type==2&&length(txtFile)==1
              movePars=dlmread(txtFile.name);
              %movePars=movePars(1:end/2,:);
              movePars=movePars(end/2+1:end,:);
              dlmwrite(strcat(txtFile.name(1:end-4),'_halfSec.txt'),movePars);
              %dlmwrite(strcat(txtFile.name(1:end-4),'_half.txt'),movePars);
              %txtFile=dir('*half.txt');
              txtFile=dir('rp*halfSec.txt');
          elseif type==2&&length(txtFile)==2
              txtSecPart=dir('rp*halfSec.txt');
              if isempty(txtSecPart)
                  movePars=dlmread(txtFile.name);
                  movePars=movePars(end/2+1:end,:);
                  dlmwrite(strcat(txtFile.name(1:end-4),'_halfSec.txt'),movePars); 
              end
              %txtFile=dir('*half.txt');
              txtFile=dir('rp*halfSec.txt');
          elseif type==1&&length(txtFile)==2
              txtFile=txtFile(1);
          end
          [NZE1,NZE2,NZE3]=ind2sub(size(Imask),find(Imask));
            for k=1:length(swurf)
            Vc=spm_vol(swurf(k).name);
            Iven(k)=mean(spm_sample_vol(Vc,NZE1,NZE2,NZE3,1));
            end
          clear swurf swurfCell
cd ..;
for fun=1:length(Nm_func)
    Nm_func(fun)=strcat(pathn,'\',D(i).name,'\',funcnm,'\',Nm_func(fun));
end
bdfFile=dir('*vlad*.dat');
if isempty(bdfFile)
    bdfFile=dir('breath*.bdf');
    if isempty(bdfFile)
        cd(pathn);
        continue;
    end
end
breathSig=extractBreath(bdfFile.name);
breathSig=breathSig(1:end/type);

%breathSig=breathSig(end/type+1:end);
Iven=Iven(1:end/type);
%Iven=Iven(end/type+1:end);
logFile=dir('*MRI*.log');
if isempty(logFile)
    cd(pathn);
    continue;
end
onsets=logParseShock(logFile.name);
mkdir(analysnm)
if exist('Nm_func','var')
if (~isempty(Nm_func))
clear matlabbatch;
firstlevel_KI_shock__job;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg={strcat(pathn,'\',D(i).name,'\',funcnm,'\',txtFile.name)};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).name='Ventricle Signal';
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).val=Iven;
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).name='Breath Signal';
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).val=breathSig;
for o=1:length(onsets)
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).name=onsets(o).type;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).onset=onsets(o).time(onsets(o).time<301*2/type);
%matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).onset=onsets(o).time(onsets(o).time>=301*2/type)-301*2/type;
if ~exist('dur','var')
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).duration=onsets(o).dur(onsets(o).time<301*2/type);
%matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).duration=onsets(o).dur(onsets(o).time>=301*2/type);
else
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).duration=0;
end
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).tmod=0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(o).pmod=[];
end
inputs{1} = {strcat(pathn,'\',D(i).name,'\',analysnm)}; % DICOM Import: DICOM files - cfg_files
    inputs{2} = TR; % DICOM Import: Output directory - cfg_files
    inputs{3} = Nm_func(:,1:end/type);
    %inputs{3} = Nm_func(:,end/type+1:end);
spm('defaults', 'FMRI');
save('model','matlabbatch');
spm_jobman('serial', matlabbatch, '', inputs{:});
if type==2
    cd(funcnm);
    delete(txtFile.name);
end
cd(pathn);
end
cd(pathn);
end
cd(pathn);
clear Nm_str;
clear Nm_func; 
    end
    cd(pathn);
end
dirs_complete=Dir;
end