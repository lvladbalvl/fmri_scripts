function [sig] = extractBreath(bdfFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
mN=10;
bN=2;
TR=2;
Td=25;
if (strcmp(bdfFile(end-2:end),'bdf'))
tmpCell=strsplit(bdfFile(1:end-4),'_');
fearNum=str2double(tmpCell{end});
numOfVols=300;
[sFile, ChannelMat] = in_fopen_edf(bdfFile);
fs=sFile.prop.sfreq;
sfid=fopen(bdfFile);
F = in_fread_edf(sFile, sfid);
F=F([bN,mN],:);
R=RRF(10/fs);
Y=find(F(2,:));
D=diff(Y);
P=find(D>7500&D<8500);
N=round(length(P)/300);
for i=1:N
    st(i)=Y(P((i-1)*299+1));
end
st(i+1)=size(F,2);
delta=0;
for i=1:N
    start=st(i)-Td*fs;
    endin=st(i)+fs*numOfVols*TR+Td*fs;
    if endin>size(F,2)
        delta=endin-size(F,2);
        endin=size(F,2);
    end
    markerGap(:,i)=cat(2,F(2,start:1:endin),zeros(1,delta));
    eegGap(:,i)=cat(2,F(1,start:1:endin),zeros(1,delta));
    F=F(:,st(i+1)-Td*fs-1:end);
    st(i+1:end)=st(i+1:end)-st(i+1)+Td*fs+1;
end
else
    [sFile, ChannelMat] = in_fopen_brainamp(bdfFile);
    sfid=fopen(bdfFile);
    F=in_fread_brainamp(sFile,sfid);
    eegGap=F(2,:)';
    fs=sFile.prop.sfreq;
    R=RRF(10/fs);
    delta=round(((600-length(F)/(fs))/2+length(R)*5/fs)*fs);
    eegGap=cat(2,ones(1,delta)*mean(eegGap),eegGap',ones(1,delta)*mean(eegGap))';
    fearNum=1;
end
[p,t]=findpeaks(eegGap(1:10:end,fearNum),'MinPeakDistance',1*fs/10,'MinPeakProminence',0.000015);
s=zeros(1,length(eegGap(1:10:end,fearNum)));
s(t)=1;
sigFull=conv(s,R,'valid');
sig=sigFull(0.1*fs:0.2*fs:end-0.1*fs);
end

