function [center] = centerOfMask(Imask,T)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[NZE1,NZE2,NZE3]=ind2sub(size(Imask),find(Imask));
cubCoords=cat(2,cat(2,NZE1,NZE2),NZE3);
mniCoords=cor2mni(cubCoords,T);
center=mean(mniCoords,1);
end

