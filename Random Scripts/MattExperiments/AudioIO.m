%% Communications Laboratory: Chapter 1
%  Audio Recorder + Player, Filtering, Upconverting + Downconverting
%% Audio Recorder + Player
% Fs = 44100;         % Sample rate in samples per second
% Nbits = 16;          % Number of bits per sample
% nChannels = 1;      % Number of channels

% Record Audio
% recObj = audiorecorder(Fs, Nbits, nChannels);
% recordblocking(recObj, 2);                      % Record 2 seconds
% sound = getaudiodata(recObj);
% figure;
% plottf(sound, 1/Fs);

% t = (0:length(sound)-1)/Fs; %sample times (sec)
% plot(t,sound);
% title('Recorded 2 Second Sound')
% xlabel('Time in seconds')
% ylabel('Amplitude value')

% Play Audio
% playObj = audioplayer(sound, Fs, Nbits);
% play(playObj)

% Play Tone
% signal = cos(2*pi*100*t);
% toneObj = audioplayer(signal, Fs);
% play(toneObj)
% plottf(signal, 1/Fs);

%% Filtering
% Fs=16000;% 16000 sps
% t=0:1/Fs:0.25;% 250 milliseconds segment
% whitenoise=randn(size(t));% Gaussian random vbls
% whitenoise = 10*whitenoise + cos(2*pi*2100*t);
% figure;
% plottf(whitenoise,1/Fs);% view signal
% title("White Noise before filtering")

% % Apply filter
% Lh = 50;                        % Impulse response length
% Fpb = 1200;                     % Passband Edge in Hz
% Fsb = 1800;                     % Stopband edge in Hz
% h = firlpf(Lh, Fpb, Fsb ,Fs);
% pinknoise=filter(h,1,whitenoise);% convolution
% figure;plottf(pinknoise,1/Fs);% view signal
% title('Original Signal')

% figure;
% plottf(h, 1/Fs)
% title('Filter')

%% Upconversion + Downconversion
% % Upconvert
% fc=4000;%4000 Hz
% s = cos(2*pi*fc*t) .* pinknoise;
% figure;plottf(s,1/Fs);
% title("Upconverted Noise")
% 
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

%% Putting it all together: Sending speech on carrier wave
Fs = 44100;         % Sample rate in samples per second
Nbits = 8;          % Number of bits per sample
nChannels = 1;      % Number of channels

% Record Audio
recObj = audiorecorder(Fs, Nbits, nChannels);
recordblocking(recObj, .9);                      % Record 2 seconds
speech = getaudiodata(recObj).';
figure;
plottf(speech, 1/Fs);
title('Recorded Speech')

% Upconvert
fc=12000;                       % Notice sampling rate >= 2*fc at 44.1khz
t =(0:length(speech)-1)/Fs;                % 250 milliseconds segment
s = cos(2*pi*fc*t) .* speech;
figure;plottf(s,1/Fs);
title("Upconverted Speech")

% Play Audio
playObj = audioplayer(s, Fs, Nbits);
play(playObj)

%% Receiving on carrier wave
% Record Audio
recObj = audiorecorder(Fs, Nbits, nChannels);
recordblocking(recObj, 2);                      % Record 2 seconds
sound = getaudiodata(recObj);
figure;
plottf(sound, 1/Fs);

% Downconvert
v = sound.* (2*cos(2*pi*fc*t));
figure;
plottf(v,1/Fs)
title("Downconverted, no LPF")

h = firlpf(49, 4200, 5000, Fs);
filtered = filter(h,1,v);
figure;
plottf(filtered,1/Fs)
title("Downconverted, w/ LPF")