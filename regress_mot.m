function [ ] = regress_mot( pathn,FMprefix,TR,rergDir )
%Регрессия от движений
%проходит по всем людям в pathn, проверяет наличие нужных файлов в фМРТ папке.
%в indFuncPrefix задан префикс функциональных файлов, которые будут регрессироваться
%это urf и swurf для данных курчатника (первый, если хотим в инд.
%пространстве, второй - если в MNI) и rf и swrf - для данных ЦПР
cd(pathn);
indFuncPrefix='urf';
z1=0;
D=dir;
V=struct;
for z=1:length(D)
    if isdir(D(z).name)&&~strcmp(D(z).name,'..')&&~strcmp(D(z).name,'.')
        cd(D(z).name);
        Din=dir;
        for j=1:length(Din)
            Dnm{j}=Din(j).name;
        end
        fmriDir=dir(strcat(FMprefix,'*'));
        if isempty(fmriDir)
            cd(pathn);
            continue;
        end
        funcnm=fmriDir.name;
        if (~any(strcmp(Dnm,funcnm)))
            disp("Func dir not found")
            cd(pathn);
            continue;
        end
        disp(strcat("Working with ",D(z).name));
        z1=z1+1;
        cd(funcnm);
        FuncImg=dir(strcat(indFuncPrefix,'*.img'));
        if isempty(FuncImg)
            disp('no func images');
            cd(pathn);
            continue;
        end
        if ~isempty(V)
            clear V;
        end
        V(1)=spm_vol(FuncImg(1).name);
        cd ..;
        if ~isempty(dir(rergDir))
            cd(rergDir);
            rDir=dir();
            if (length(rDir)>3)
                disp('already processed. Skipped');
                %rmdir('regress','s');
                cd(pathn);
                continue;
            end
            cd ..;
        end
        mkdir(rergDir);
        cd(funcnm);
        rpTxt=dir('*.txt');
        RFuncImg=dir(strcat(indFuncPrefix,'*.img'));
        RFuncImgCell=struct2cell(RFuncImg);
        RFuncImgNames=RFuncImgCell(1,:);
        for i=1:length(RFuncImgNames)
        RFuncImgNames(i)={strcat(pathn,'\',D(z).name,'\',funcnm,'\',RFuncImgNames{i})};
        end
        regressout_wo_ventr_job;
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg={strcat(pathn,'\',D(z).name,'\',funcnm,'\',rpTxt(1).name)};
            inputs{1} = {strcat(pathn,'\',D(z).name,'\',rergDir)}; % fMRI model specification: Directory - cfg_files
            inputs{2} = TR; % fMRI model specification: Interscan interval - cfg_entry
            inputs{3} = RFuncImgNames; % fMRI model specification: Scans - cfg_files
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch, '', inputs{:});
        clear matlabbatch;
   end
            cd(pathn);
end
end
