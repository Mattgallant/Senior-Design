% Record Audio
Fs = 44100;         % Sample rate in samples per second
Nbits = 8;          % Number of bits per sample
nChannels = 1;      % Number of channels
fc = 12000;

recObj = audiorecorder(Fs, Nbits, nChannels);
recordblocking(recObj, 1);                      % Record 2 seconds
sound = getaudiodata(recObj);
figure;
plottf(sound, 1/Fs);
title('Received Sound')

% Downconvert
t =(0:length(sound)-1)/Fs;              
v = sound.' .* (2*cos(2*pi*fc*t));
figure;
plottf(v,1/Fs)
title("Downconverted, no LPF")

h = firlpf(49, 4200, 5000, Fs);
filtered = filter(h,1,v);
figure;
plottf(filtered,1/Fs)
title("Downconverted, w/ LPF")

% Play Audio
playObj = audioplayer(40*filtered, Fs, Nbits);
play(playObj)