function [pVal,pValLink,pValLinkPerNode,clusters,links,linksPerNode] = NetBasedStat2Samp(CC1,CC2,M)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%CC1Z=0.5*log((1+CC1)./(1-CC1));
%CC2Z=0.5*log((1+CC2)./(1-CC2));
CC1Z=CC1;
CC2Z=CC2;
f = waitbar(0,'Please wait...');
for i=1:M
    [CC1Zn,CC2Zn]=matr_permute(CC1Z,CC2Z);
    for k=1:size(CC1Z,2)
        p(k)=ranksum(CC1Zn(:,k),CC2Zn(:,k));
    end
    [clusters,links,linksPerNode]=NBS_find_clusters(p<0.05);
    maxLinkPerNodeSize(i)=max(linksPerNode);
    maxLinkSize(i)=max(links);
    maxClustSize(i)=max_clust_size(clusters);
    waitbar(i/M,f,sprintf('%f',i/M))
end
maxLinkPerNodeSizeUnique=unique(maxLinkPerNodeSize);
maxLinkSizeUnique=unique(maxLinkSize);
maxClustSizeUnique=unique(maxClustSize);
for k=1:length(maxLinkPerNodeSizeUnique)
    pValLinkPerNode(maxLinkPerNodeSizeUnique(k))=length(find(maxLinkPerNodeSize>=maxLinkPerNodeSizeUnique(k)))/M;
end
for k=1:length(maxLinkSizeUnique)
    pValLink(maxLinkSizeUnique(k))=length(find(maxLinkSize>=maxLinkSizeUnique(k)))/M;
end
for k=1:length(maxClustSizeUnique)
    pVal(maxClustSizeUnique(k))=length(find(maxClustSize>=maxClustSizeUnique(k)))/M;
end
for k=1:size(CC1Z,2)
    p(k)=ranksum(CC1Z(:,k),CC2Z(:,k));
end
[clusters,links,linksPerNode]=NBS_find_clusters(p<0.05);
end

function [cluster,links,linksPerNode] = NBS_find_clusters(pair_linkage)
    cluster=[];
    Conn = tosymmetric(pair_linkage);
    Conn2 = Conn;
    Conn2(:,:,2)=Conn*Conn;
    i=2;
    links=[];
    linksPerNode=[];
    while ~(all(reshape(((Conn2(:,:,i)>0)-(Conn2(:,:,i-1)>0)),1,size(Conn2,1)*size(Conn2,2))==0))
        i=i+1;
        Conn2(:,:,i)=Conn*Conn2(:,:,i-1);
    end
    Conn3=Conn2(:,:,i)>0;
    i=1;
    already_checked=[];
    for k=1:size(Conn3,1)
        linksPerNode(k)=sum(Conn(k,:))-1;
        if any(already_checked==k)
            continue
        end
        tmp=find(Conn3(k,:)>0);
        if i>1
            def=size(cluster,2)-length(tmp);
            if def<0
                cluster=cat(2,cluster,zeros(size(cluster,1),-def));
            elseif def>0
                tmp=[tmp zeros(1,def)];
            end
            
        end
        cluster=cat(1,cluster,tmp);
        links=cat(1,links,(sum(sum(Conn(tmp(tmp>0),:)))-length(tmp(tmp>0)))/2);
        already_checked=[already_checked unique(tmp)];
        i=i+1;
    end
end

function [CC1Zn,CC2Zn]=matr_permute(CC1Z,CC2Z)
    CCf=cat(1,CC1Z,CC2Z);
    CC1Zn=[];
    CC2Zn=[];
    for i=1:size(CCf,1)
        p=rand(1,1);
        if p<0.5
            CC1Zn(end+1,:)=CCf(i,:);
        else 
            CC2Zn(end+1,:)=CCf(i,:);
        end
    end
end

function maxClustSize = max_clust_size(cluster)
    maxClustSize=0;
    for i=1:size(cluster,1)
        m=length(find(cluster(i,:)));
        if m>maxClustSize
            maxClustSize=m;
        end
    end
end
