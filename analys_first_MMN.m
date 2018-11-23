function [ list] = analys_first_MMN( pathn, funcnm,structnm, analysnm,mask)
%анализ первого уровня MMN данных
% проходит по всем испытуемым, проверяет у каждого наличие нужных файлов в
% папках заданных как funcnm и structnm. Проверяет есть ли заполненная
% папка analysnm. Если нет - читает лог, берет оттуда онсеты и запускает
% анализ. При анализе регрессирует на движения и на сигнал в желудочках.
% Путь к файлу в желудочках (в общем пространстве) задается через mask
blocks={};

s=0;
silence=0;
TR=3;
cond_dur=0;
p=zeros(length(blocks),1);
disp('Searching for directories for 1-st level analysis');

 blocks={'Base' 'MMM' 'MMN'};
if pathn(length(pathn))~='\'
    pathn=cat(2,pathn,'\');
end
cd(pathn);
D=dir;
n=0;
for i=3:length(D)
    q=0;
    do=0;
    n=n+1;
    Din={};
    Dnm={};
    if D(i).isdir==1
        cd(D(i).name);
        Din=dir;
        for k=1:length(Din)
            Dnm{k}=Din(k).name;
        end
        if (any(strcmp(Dnm,funcnm)))&&(any(strcmp(Dnm,structnm)))&&((~any(strcmp(Dnm,analysnm)))||(length(dir(analysnm))<3))

          cd(funcnm);
          list=ls;
          swrfn=strmatch('swrf',list(:,1:4))';
          FuncImg=dir('rf*.img');
          txtFile=dir('rp*.txt');
          if ~isempty(swrfn)
              do=1;
            q=q+1;
            Dir{q}=D(i).name;
            disp(sprintf('================================\nWorking with %s\n================================',Dir{q}));
          Dfunc=dir;
          for k=1:length(swrfn)
              swrf{k}=sprintf('%s%s%s%s%s%s',pathn,Dir{q},'\',funcnm,'\',Dfunc(swrfn(k)).name);
          end
          cd ..;
          cd(structnm);
                    wfu_to_individ_job;
                    wmsFile=dir('wms*.nii');
                    matlabbatch{1}.spm.spatial.coreg.write.ref={wmsFile.name};
                    matlabbatch{1}.spm.spatial.coreg.write.source={mask};
                    inverseDefFile=dir('iy_s*.nii');
                    matlabbatch{2}.spm.util.defs.comp{1}.def={inverseDefFile.name};
                    matlabbatch{2}.spm.util.defs.savedir.saveusr={strcat(pathn,'\',D(i).name,'\',structnm)};
                    matlabbatch{3}.spm.spatial.coreg.write.ref={strcat(pathn,'\',D(i).name,'\',funcnm,'\',FuncImg(1).name)};
                    spm('defaults', 'FMRI');
                    spm_jobman('serial', matlabbatch, '', '');
                    clear matlabbatch;
                    Imask=spm_read_vols(spm_vol('rwrmaskventricles.nii'));
cd ..;
cd(funcnm);
%rpTxt=dir('*.txt');
RFuncImg=dir('rf*.img');

[NZE1,NZE2,NZE3]=ind2sub(size(Imask),find(Imask));
for id=1:length(RFuncImg)
Vc=spm_vol(RFuncImg(id).name);
Iven(id)=mean(spm_sample_vol(Vc,NZE1,NZE2,NZE3,1));
end
          cd ..;
          if ~any(strcmp(Dnm,analysnm))
          mkdir(analysnm);
          disp(sprintf('%s directory created in %s\n',analysnm,Dir{q}));
          end


   %     filename=sprintf(,strtok(D(i).name,'_'));
% здесь парсит лог файл и получает релевантную информацию по времени
% онсетов. К времени сканов приводится уже позже
   filename=dir('*.log');
file=fileread(filename.name);
beg=regexp(file,'Paradigm Begin','start');
for w=1:length(blocks)
    clear r;
    r=beg(length(beg))+regexp(file(beg(length(beg)):length(file)), blocks{w}, 'end');
    for k=1:length(r)
        try
        if ~isnan(str2double(file((r(k)+26):1:(r(k)+32))))
        p(w,k)=str2double(file((r(k)+26):1:(r(k)+32)));
        else p(w,k)=0;
        end
        catch
        disp('sdf');    
        end
    if isnan(p(w,k))
        p(w,k)=0;
    end

    end

end
          else
              do=0;
          end

cd(pathn);
        else
            disp(sprintf('Skipped %s',D(i).name));
        end

    end
P=size(p);
if do
    clear matlabbatch;
% в память загружается структура батча analys_first_MMN__job. В ней нужно
% задать онсеты, их время и длительность, multi_reg поле для регрессеров
% движения и regress для сигнала желудочков
analys_first_MMN__job;
[h,k]=size(p);

if P(2)<2||P(1)<length(blocks)
    disp(sprintf('Other block names in %s',Dir{q}));
 continue;
end
[w1,q1]=size(p);
sil_p=[];
%обрезаются всякие неправильный тайм поинты и дальше для всех блоков
%берутся времена для 5го и 8го слога, сворачиваются с hrf и далее
%даунсемплятся на времена сканов МРТ
p=p.*(p<max(max(p)));
hrf=spm_hrf(0.1);
for cn=1:length(blocks)
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cn).name = blocks{cn};

if p(cn,1)==0
    disp('first p == 0');
pnm= p(cn,2:end)>0;
p_cur=cat(2,p(cn,pnm),p(cn,end));
else
    pnm=p(cn,:)>0;
    p_cur= p(cn,pnm)-3.2+12.5;
end
p_cur2=p_cur-0.85*3;
p_cur2=fix(p_cur2*10)/10;
p_cur=union(p_cur,p_cur2);
x=zeros(1,length(0.1:0.1:1125));
vp=round(p_cur*10);
x(vp)=1;
vx=conv(x,hrf);
o=vx(125:125:end);
o=o(1:90);
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cn).val = o;
end
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg={strcat(pathn,'\',D(i).name,'\',funcnm,'\',txtFile.name)};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cn+1).name = 'Ventricle Signal';
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(cn+1).val = Iven;
inputs{1} = {sprintf('%s%s%s%s',pathn,Dir{q},'\',analysnm)}; % путь к папке с анализом
inputs{2} = TR; % хотя ТР один и тот же - я его не стал задавать в батче, а задаю через скрипт
inputs{3} = swrf; % список файлов в общем пространстве с префиксом swrf
spm('defaults', 'FMRI');
matlabbatch{1}.spm.stats.fmri_spec.dir={sprintf('%s%s%s%s',pathn,Dir{q},'\',analysnm)}; %почему то я здесь опять записываю путь к папке с анализом
matlabbatch{1}.spm.stats.fmri_spec.timing.RT=TR;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans=swrf;
save(sprintf('%s%s%s%s\\%s',pathn,Dir{q},'\',analysnm,'model.mat'),'matlabbatch'); %сохраняется модель - можно проверить
spm_jobman('serial', matlabbatch, '', inputs{:}); %запускается spm
clear matlabbatch;
end
cd(pathn);
end
list=Dir{q};
end

