function [corrMatrix,T ] = fmri_parcellation( sessDir,fmriDirName,mask,Nc)
%������������ ������� �� mask �� ��������� ��������� �������� ������ ���
%   ��������� �� ����� �� sessDir, ������ ������� ���� ���� ����� � ��������� fmriDirName
% ������ ��� ���� ����� � ��������� fmriFilePrefix (��� ������� ���
% ���������������, ������� ResI). mask - ���������� ���� � ����� � ������
% ������ ���-�� ���������, ��������� ������� ������� �������� ����� Nc
% �� � ���� ���� ���� ������������������ ������, ������� ��������� ������
% ���������: ���������� ������� �� ������������ ������� �������� - ������
% 100 ��������. ������ ����� ����������� ���-�� ���������, ���� �� ��������
% ���� �� ���� �����, ������ �������� ������ ������ � ���������
% ��������������� ����� Nc-1 (�.�. ��������� ���, �� �������� ����� �����)
% ��� ����, ����� ��������� ������� ��������� ������� �������� ����������
% ����� ����� ���������, ����� �������������� ����� �������������
% �������������: ������ ������ ������������ ��������� ����������� �������
% �� ����� ���������� � �������������� ��������� ���������� ����� �����
% ���������
for s=1:length(sessDir)
    cd(sessDir{s});
    fmriFilePrefix='ResI';
    D=dir;
    z=0;
    corrMatrix=[];
    maskPathCell=strsplit(mask,'\');
    maskName=maskPathCell{end}(1:end-4);
    for i=1:length(D)
        if strcmp(D(i).name,'..')||strcmp(D(i).name,'.')||~D(i).isdir
            disp(strcat('Skipped',D(i).name));
            continue;
        end
        try
            cd(D(i).name);
        catch
            continue;    
        end
        fmriDir=dir(strcat(fmriDirName,'*'));
        if (length(fmriDir)~=1)
            disp('Not found fmriDir or two many directories found');
            cd(sessDir{s});
            continue;
        end
        cd(fmriDir.name);
        FuncImg=dir(strcat(fmriFilePrefix,'*.img'));
        Imask=spm_read_vols(spm_vol(mask));
        [NZE1,NZE2,NZE3]=ind2sub(size(Imask),find(Imask));
        cd(fmriDir.name);
        if isempty(FuncImg)
            disp('Func images not found');
            cd(sessDir{s});
            continue;
        end
        z=z+1;
        for k=1:length(FuncImg)
            Vc=spm_vol(FuncImg(k).name);
            funcIMask(k,:)=(spm_sample_vol(Vc,NZE1,NZE2,NZE3,1));
        end
        if ~isempty(find(isnan(funcIMask)))
            disp(strcat('Nan values for ',fmriFilePrefix,'files in ',D(i).name));
            cd(sessDir{s});
            continue;
        end
        corrMatrix=cat(1,corrMatrix,corrcoef(funcIMask));
        cd(sessDir{s});
    end
end
    Z=linkage(corrMatrix','ward','euclidean');
%     Clsize=11;
     j=Nc;
%     while all(Clsize>10)
%         j=j+1;
%         T=cluster(Z,'Maxclust',j);
%         u=unique(T);
%         Clsize=zeros(1,length(u));
%         for i=1:length(u)
%         Clsize(i)=length(find(T==u(i)));
%         end
%     end
%    T=cluster(Z,'Maxclust',j-1);
    T=cluster(Z,'Maxclust',Nc);
    V=spm_vol(mask);
    for k=1:j
        Mask1NZE=[NZE1(T==k) NZE2(T==k) NZE3(T==k)]';
        Im=zeros(size(Imask));
        idx=sub2ind(size(Im),Mask1NZE(1,:),Mask1NZE(2,:),Mask1NZE(3,:));
        Im(idx)=1;
        V.fname=strcat(maskName,'parce',num2str(k),'_of_',num2str(j),'.nii');
        spm_write_vol(V,Im);
    end
end

