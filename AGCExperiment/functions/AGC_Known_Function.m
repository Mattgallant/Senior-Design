%-----AGC_Known_Function------
%Stabilizes the amplitude of a received signal given that he original is
%known
%Inputs:    r - the signal to be equalized
%           knownSignal - the known original signal
%Outputs:   signal - the signal after amplitude equalization
%           estimation - gain factor estimation
function [signal, estimation] = AGC_Known_Function(r, knownSignal)
    %agc
    estimation = r./knownSignal;
    signal = r ./ division;
   
end

% % % draw agcgrad.eps
% subplot(3,1,1)
% plot(signal)              
% title('Known signal')
% axis([0,n,-25,25])
% subplot(3,1,2)
% plot(r,'r')          % plot inputs and outputs
% axis([0,n,-25,25])
% title('Input')
% subplot(3,1,3)
% plot(estimate,'b')
% axis([0,n,-25,25])
% title('Output')
