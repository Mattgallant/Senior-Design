%NOTE this script's math is is adapted almost word-for-word from the MATLAB example here:
%https://www.mathworks.com/help/comm/examples/raised-cosine-filtering.html#d120e18189
%Added unity gain
%Manipulated resulting grpah
%Added example bitstream for use in direct comparison
%Started work on carrier modulation
Nsym = 6;           % Filter span in symbol durations - default
beta = 0.5;         % Roll-off factor - default 
sampsPerSym = 6;    % Upsampling factor - aslso helps to smoothen out the graph

% Parameters
DataL = 5000;             % Data length in symbols
R = 500;               % Data rate (symbols per second)
Fs = R * sampsPerSym;   % Sampling frequency, set to 500*6 = 3000, samples = cycles
Fc = 300;               %Carrier frequency, 300Hz

%NMW Getting 3x the difference Fc seems to not matter? HAS TO DO WITH Fs
%and to

%Example Bitstream mapped with BPSK
x =  2*randi([0 1],DataL,1) - 1;
x_up = upsample(x,sampsPerSym);
%(optional) print bitstream and size array-dimensions of bitstream
%fprintf("%d ",bitstream);
%fprintf("\n");
%fprintf("%d, ",size(bitstream));

% Time vector sampled at symbol rate in milliseconds
tx = 1000 * (0: DataL - 1) / R;

% Filter group delay, since raised cosine filter is linear phase and
% symmetric.
fltDelay = Nsym / (2*R);
to = 1000 * (0: DataL*sampsPerSym - 1) / Fs;

% Design raised cosine filter with given order in symbols
rctFilt3 = comm.RaisedCosineTransmitFilter(...
  'Shape',                  'Square root', ...
  'RolloffFactor',          beta, ...
  'FilterSpanInSymbols',    Nsym, ...
  'OutputSamplesPerSymbol', sampsPerSym);

%fvtool(rctFilt3)

%set unity passband gain and verify it's 1
b = coeffs(rctFilt3);
rctFilt3.Gain = 1/sum(b.Numerator);
bNorm = coeffs(rctFilt3);
sum(bNorm.Numerator)

% Upsample and filter.
yc = rctFilt3([x; zeros(Nsym/2,1)]);
% Correct for propagation delay by removing filter transients
yc = yc(fltDelay*Fs+1:end);
%Convolution, Thanks Javi :)
yc_conv = conv(x_up,yc);
%message, phase modulation of filtered signal
tc = 1000 * (0:DataL*sampsPerSym-1) / Fc; %The time vector for the specified frequency
message = yc_conv*cos(2*pi*to*Fc); %The filtered message y values


%figure(1)
%spectrumAnalyzer = dsp.SpectrumAnalyzer('SampleRate',1000);
%spectrumAnalyzer(yc)

figure(2)
% Plot data.
stem(tx(1:100), x(1:100), 'kx'); hold on;
% Plot filtered data.
plot(to(1:500), yc(1:500), 'm-'); hold off;
% Set axes and labels.
axis([-1 100 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude');
legend('Mapped-Bitstream', 'Sqrt. Raised Cosine', 'Location', 'southeast');


figure(3)
%modulate on cosine carrier of 1kHz
plot(message(1:500),'m-'); hold off;
axis([-1 100 -1.7 1.7]); xlabel('Time (ms)'); ylabel('Amplitude');
legend('Modulated SRRC Data','Location','southeast');

