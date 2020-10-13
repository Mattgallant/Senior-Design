% Messing around with training sequence detection
Fs = 44100;
fc = 9000;
dt = 1/Fs;

%% Transmitter
pilots=[1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1];

% Generate Data
y = zeros(1,100);   

% Add Training Seq
tau = 0;                                       %delay >= 0; start=1+tau
y((1+tau) : (1+tau)+length(pilots)-1) = pilots; %Insert pilots in
figure; 
plottf(y, 1/Fs);
title("Data w/ Sequence");

%  SRRC Filtering
rolloff = 0.10;
span = 10;
sps = 1;
M = 2;
k = log2(M);

rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
y = upfirdn(real(y), rrcFilter, sps);

figure;
plottf(rrcFilter, 1);
title("Filter");
figure;
plottf(y, 1/Fs);
title("Signal after SRRC");

% Upconvert
t = (0:dt:(length(y) - 1)/Fs);
s = cos(2*pi*fc*t) .* y;
figure;
plottf(s,1/Fs);
title("Upconverted Noise")

% % Downconvert
% v = s .* (2*cos(2*pi*fc*t));
% figure;
% plottf(v,1/Fs)
% title("Downconverted, no LPF")
% 
% h = firlpf(49, 4200, 5000, Fs);
% filtered = filter(h,1,v);
% figure;
% plottf(filtered,1/Fs)
% title("Downconverted, w/ LPF")

%% Channel
% y = awgn(y, 20);
y = [randi([0 1],100, 1).' y];                  % Add random bits to start of seq

%% Receiver

% Training Detection
xc=conv(y,fliplr(pilots));                      % auto-correlation

figure;
stem(xc);
xlabel('lag number');
title('autocorrelation')

[value,indx] = max(abs(xc));
peak = xc(indx);
trainStartIdx = indx - length(pilots);           % Starting index of training seq. Should be equal to tau

receivedData = y(indx+1:end);