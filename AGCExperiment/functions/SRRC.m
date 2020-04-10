function yc = SRRC(x,Nsym,beta,sampsPerSym,R,Fc)
%NOTE this script's math is is adapted almost word-for-word from the MATLAB example here:
%https://www.mathworks.com/help/comm/examples/raised-cosine-filtering.html#d120e18189
%Added unity gain
%Manipulated resulting grpah
%Added example bitstream for use in direct comparison
%Started work on carrier modulation
%Nsym = 6;           % Filter span in symbol durations - default
%beta = 0.5;         % Roll-off factor - default 
%sampsPerSym = 6;    % Upsampling factor - aslso helps to smoothen out the graph

% Parameters
%DataL = 8;             % Data length in symbols
%R = 500;               % Data rate
%Fs = R * sampsPerSym;   % Sampling frequency
%Fc = 1000;               %Carrier frequency, 1kHz

%Example Bitstream mapped with BPSK
%Note: must be a column vector e.g. (1,elements)
%x = [ 1; -1; 1; 1; -1; -1; -1; 1];

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

%set unity passband gain and verify it's 1
b = coeffs(rctFilt3);
rctFilt3.Gain = 1/sum(b.Numerator);
%bNorm = coeffs(rctFilt3);
%sum(bNorm.Numerator)

% Upsample and filter.
yc = rctFilt3([x; zeros(Nsym/2,1)]);
% Correct for propagation delay by removing filter transients
yc = yc(fltDelay*Fs+1:end);
%Convert to carrier Frequency Fc
%phasedev = pi/2;
yc = yc*cos(2*pi*tx*Fc);
%message = pmmod(signal,Fc,Fs,phasedev);

end