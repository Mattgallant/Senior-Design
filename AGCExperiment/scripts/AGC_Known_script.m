
%generate a signal with envelope (to see agc working)
n = 10000;
signal = 5*randn(n,1);                      % generate random inputs
data = signal+ 3*(randn(n,1));              % add noise
env = 0.5 + abs(sin(2*pi*[1:n]'/n));  % the fading profile
r = data.*env;                          % apply to raw input r[k]

%MLE agc
division = r./signal;
estimate = r ./ division;

%BER = biterr(signal, estimate)

% % draw agcgrad.eps
subplot(3,1,1)
plot(signal)              
title('Known signal')
axis([0,n,-25,25])
subplot(3,1,2)
plot(r,'r')          % plot inputs and outputs
axis([0,n,-25,25])
title('Signal through noise & fading')
subplot(3,1,3)
plot(estimate,'b')
axis([0,n,-25,25])
title('AGC Output')
