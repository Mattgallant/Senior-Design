%-----AGC_Known_Function------
%Stabilizes the amplitude of a received signal given that he original is
%known
%Inputs:    r - the signal to be equalized
%           knownSignal - the known original signal
%Outputs:   estimation - gain factor estimation   
function estimation = AGC_Known_Function(r, knownSignal)
    %agc
    estimation = sum(r./knownSignal) / length(r);   %1/N * sum(r[n]/s[n])
   
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
