%NOTE this script is adapted almost word-for-word from the MATLAB example here:
%https://www.mathworks.com/help/comm/examples/raised-cosine-filtering.html#d120e18189
Nsym = 6;           % Filter span in symbol durations - default
beta = 0.5;         % Roll-off factor - default 
sampsPerSym = 6;    % Upsampling factor - aslso helps to smoothen out the graph

% Parameters
DataL = 8;             % Data length in symbols
R = 500;               % Data rate
Fs = R * sampsPerSym;   % Sampling frequency
Fc = 9000;               %Carrier frequency, 9kHz
n = 0:(DataL*Fs/R-1);

%Example Bitstream mapped with BPSK
%Note: must be a column vector e.g. (1,elements)
x = [1; -1; 1; 1; -1; -1; -1; 1];

%(optional) print bitstream and size array-dimensions of bitstream
fprintf("%d ",bitstream);
fprintf("\n");
fprintf("%d, ",size(bitstream));

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

%set unity passband gain and verify it's 1
b = coeffs(rctFilt3);
rctFilt3.Gain = 1/sum(b.Numerator);
bNorm = coeffs(rctFilt3);
sum(bNorm.Numerator)

% Upsample and filter.
yc = rctFilt3([x; zeros(Nsym/2,1)]);
% Correct for propagation delay by removing filter transients
yc = yc(fltDelay*Fs+1:end);
%message filter * carrier wave 
message = yc.*cos(2*pi*Fc/Fs*n);

figure(1)
% Plot data.
stem(tx, x, 'kx'); hold on;
% Plot filtered data.
plot(to, yc, 'm-'); hold off;
% Set axes and labels.
axis([-1 DataL*2 -1.7 1.7]);  xlabel('Time (ms)'); ylabel('Amplitude');
legend('Mapped-Bitstream', 'Sqrt. Raised Cosine', 'Location', 'southeast');


%figure(2)
%modulate on cosine carrier of 8kHz
%plot(message, 'm-'); hold on;
%axis([-1 DataL*8 -1.7 1.7]); xlabel('Time (ms)'); ylabel('Amplitude');
%legend('Modulated SRRC Data','Location','southeast');

