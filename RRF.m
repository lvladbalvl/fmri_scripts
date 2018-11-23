function [ RRF ] = RRF( dt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
T=50;
N=T/dt;
t=0:dt:T;
RRF=0.6*(t.^2.1).*exp(-t./1.6)-0.0023*(t.^3.54).*exp(-t./4.25);

end

