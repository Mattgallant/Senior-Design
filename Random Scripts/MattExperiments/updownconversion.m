Fs=44100;% 16000 sps
t=0:1/Fs:0.25;% 250 milliseconds segment
whitenoise=randn(size(t));% Gaussian random vbls
whitenoise = 10*whitenoise;
figure;
plottf(whitenoise,1/Fs);% view signal
title("White Noise before filtering")

% Apply filter
Lh = 50;                        % Impulse response length
Fpb = 1200;                     % Passband Edge in Hz
Fsb = 1800;                     % Stopband edge in Hz
h = firlpf(Lh, Fpb, Fsb ,Fs);
pinknoise=filter(h,1,whitenoise);% convolution
figure;plottf(pinknoise,1/Fs);% view signal
title('Original Signal')

% figure;
% plottf(h, 1/Fs)
% title('Filter')

% Upconversion + Downconversion
% Upconvert
fc=9000;%4000 Hz
s = cos(2*pi*fc*t) .* pinknoise;
figure;plottf(s,1/Fs);
title("Upconverted Signal")

% Downconvert
v = s .* (2*cos(2*pi*fc*t));
figure;
plottf(v,1/Fs)
title("Downconverted, no LPF")

h = firlpf(49, 4200, 5000, Fs);
filtered = filter(h,1,v);
figure;
plottf(filtered,1/Fs)
title("Downconverted, w/ LPF")