function [ CC] = ROI_CC( pathn,funcnm,structnm, compnums,TR )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
cd(pathn);
filtflag=1;
[B,A]=butter(3,[0.01*2*TR 0.1*2*TR]);
dt=2;
z1=0;
funcPrefix='ResI';
LabelFileGz=struct;
for i=1:length(compnums)
    cellcomp=textscan(compnums{i},'%d','delimiter','+');
    cellcomp=cellcomp{1};
    if length(cellcomp)==2
        comps(i,1)=cellcomp(1);
        comps(i,2)=cellcomp(2);
    else
        comps(i,1)=cellcomp;
        comps(i,2)=0;
    end
end
D=dir;
for z=3:length(D)
    if isdir(D(z).name)
        cd(D(z).name);
        Din=dir;
        for k=1:length(Din)
            Dnm{k}=Din(k).name;
        end
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
FuncImg=dir(strcat(funcPrefix,'*.img'));
V(1)=spm_vol(FuncImg(1).name);
cd ..;
cd(structnm);
StructFile=dir('s*.img');
if length(StructFile)>1
StructFile=StructFile(1);
end
StructVol=spm_vol(StructFile.name);
AtlasInfo=xml2struct('brainsuite_labeldescription.xml');
compnames=component_names(AtlasInfo,comps);
LabelFileGz=struct;
RLabelFile=dir('r*svreg.label.nii');
if isempty(RLabelFile)
LabelFileGz=dir('*svreg.label.nii.gz');
if isempty(LabelFileGz)
    LabelFileD=dir('*svreg.label.nii');
    LabelFile{1}=LabelFileD.name;
    if isempty(LabelFile)
        disp('no label file and no gz file');
    end
else
LabelFile=gunzip(LabelFileGz.name);
end
V(2)=spm_vol(LabelFile{1});
V(2).mat=StructVol.mat;
spm_reslice(V, struct('mean',false ,'which' ,1,'interp' , 0 , 'mask' , 0)) ;
Vlabel=spm_vol(strcat('r',LabelFile{1}));
else
    Vlabel=spm_vol(RLabelFile.name);
end
try
ILabel=round(spm_read_vols(Vlabel));
catch
    disp('sdf');
end
cd ..;
cd(funcnm);
RFuncImg=dir(strcat(funcPrefix,'*.img'));
for i=1:length(RFuncImg)
    Vc(i)=spm_vol(RFuncImg(i).name);
end
CC(z1).patient=D(z).name;
p=length(comps);
k=0;
qq=0;
for k1=1:length(comps)-1
    k=k+1;
    j=k;
    Imask1=mk_mask(comps(k,:),ILabel,1);
    [NZE1,NZE2,NZE3]=ind2sub(size(Imask1(:,:,:)),find(Imask1(:,:,:)));
    If1=zeros(length(RFuncImg),1);
    for v=1:length(RFuncImg)
        Ifc=spm_sample_vol(Vc(v),NZE1,NZE2,NZE3,1);
        Ifc(isnan(Ifc))=0;
        If1(v)=mean(Ifc);
    end
        if filtflag
            Tc1=filtfilt(B,A,If1);
        else
        Tc1=squeeze(mean(mean(mean(If.*Imask1,3),2),1));    
        end
    for j1=(k+1):length(comps)
        qq=qq+1;
        j=j+1;
        if comps(j,1)==1224
            disp('sdf');
        end
        Imask2=mk_mask(comps(j,:),ILabel,1);
            [NZE1,NZE2,NZE3]=ind2sub(size(Imask2(:,:,:)),find(Imask2(:,:,:)));
        If2=zeros(length(RFuncImg),1);
        for v=1:length(RFuncImg)
            Ifc=spm_sample_vol(Vc(v),NZE1,NZE2,NZE3,1);
            Ifc(isnan(Ifc))=0;
            If2(v)=mean(Ifc);
        end
        if filtflag
        Tc2=filtfilt(B,A,If2);
        else
        Tc2=squeeze(mean(mean(mean(If.*Imask2,3),2),1));    
        end
        if Imask1==0
            disp('Imask1=0');
            disp(compnames{k});
            comps(k,:)=[];
            compnames(k)=[];
            if j==p
            break;
            end
            p=p-1;
            j=j-1;
            continue; 
        end
        if Imask2==0
            disp('Imask2=0');
            disp(compnames{j});
            comps(j,:)=[];
            compnames(j)=[];
            j=j-1;
            p=p-1;
            if j==p
            break;
            end
            continue;
        end
        maxCC=0;
        %CC1=corrcoef(Tc1,Tc2);
        for l=-dt:dt
            l1=-(l-abs(l))/2;
            l2=(l+abs(l))/2;
        CC1=corrcoef(Tc1(l2+1:end-l1),Tc2(l1+1:end-l2));
        if abs(CC1(1,2))>abs(maxCC)
            maxCC=CC1(1,2);
        end
        end
        CC(z1).value(qq)=CC1(1,2);
        CC(z1).name{qq}=strcat(compnames(k),' - ',compnames(j));
        if j==p
            break;
        end
    end
end
    end
    cd(pathn);
    end
end
function [Imask] = mk_mask(comp,ILabel,n)
if comp(2)==0
    Imask=repmat(ILabel==comp(1),1,1,1,n);
elseif comp(2)==comp(1)
     [P1,P2,P3] = ind2sub(size(ILabel),find(ILabel == comp(1)));
     Mid=(max(P2)+min(P2))/2;
     ILabel(:,1:Mid,:)=0;
     Imask=repmat(ILabel==comp(1),1,1,1,n);
elseif comp(2)==(-comp(1));
     [P1,P2,P3] = ind2sub(size(ILabel),find(ILabel == comp(1)));
     Mid=(max(P2)+min(P2))/2;
     ILabel(:,Mid:end,:)=0;
     Imask=repmat(ILabel==comp(1),1,1,1,n);
else
    Imask=repmat(ILabel==comp(1),1,1,1,n)+repmat(ILabel==comp(2),1,1,1,n);
end
end
function compnames = component_names(AtlasInfo,comps)
for i=1:length(AtlasInfo.labelset.label)
    if any(str2double(AtlasInfo.labelset.label{i}.Attributes.id)==comps(:,1))
        k=find(comps(:,1)==str2double(AtlasInfo.labelset.label{i}.Attributes.id));
        try
        compnames{k}=AtlasInfo.labelset.label{i}.Attributes.fullname;
        catch
        compnames{k(1)}=  strcat('anter',AtlasInfo.labelset.label{i}.Attributes.fullname);
        compnames{k(2)}=  strcat('poster',AtlasInfo.labelset.label{i}.Attributes.fullname);
        end
        if comps(k,2)>0
            compnames{k}=compnames{k}(2:end);
        end
    end
end
end
