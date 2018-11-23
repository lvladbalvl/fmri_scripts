function [ S ] = tosymmetric( M,varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if isempty(varargin)
    N=length(M);
    n=(1+(1+8*N)^(1/2))/2;
    row=1;
    col=2;
    for i=1:N
        S(row,col)=M(i);
        col=col+1;
        if col==n+1
            row=row+1;
            col=row+1;
        end
    end
    S(row,:)=zeros(1,n);
    S=S+S';
    for i=1:size(S,1)
        S(i,i)=1;
    end
else
    if strcmp(varargin{1},'back')
        n=size(M,1);
        N=n*(n-1)/2;
        row=1;
        col=2;
        for i=1:N
            S(i)=M(row,col);
            col=col+1;
            if col==n+1
                row=row+1;
                col=row+1;
            end
        end
    end
end
end

