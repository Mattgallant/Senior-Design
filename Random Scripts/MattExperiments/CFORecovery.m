% A place to mess around with CFO recovery and figure out wtf is going on

fs = 44100;
sps = 4;
M = 2;
k = log2(M);          % Bits per symbol

constdiagram = comm.ConstellationDiagram(...
    'ReferenceConstellation',[-1 1], ...
    'SamplesPerSymbol',sps, ...
    'SymbolsToDisplaySource','Property','SymbolsToDisplay',4000, ...
    'XLimits',[-5 5],'YLimits',[-5 5]);

%% Transmitter

% Generate Data
data = randi([0 M-1],10000,1);

% Modulate
modSig = pskmod(data,M);

% SRRC Filter
rolloff = 0.25;
span = 10;
sps = 6;
M = 2;
k = log2(M);

% Our RRC Filter
rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
pulseShaped = upfirdn(modSig, rrcFilter, sps);

% Alternate SRRC Filter
% txfilter = comm.RaisedCosineTransmitFilter('OutputSamplesPerSymbol',sps, ...
%     'Gain',1);
% rxfilter = comm.RaisedCosineReceiveFilter('InputSamplesPerSymbol',sps, 'DecimationFactor', sps);
% txSig = txfilter(modSig);
txSig = upconvert(pulseShaped.');
% txSig = pulseShaped;
%% Channel
% Setup channel objects
channel = comm.AWGNChannel('EbNo',10,'BitsPerSymbol',k,'SamplesPerSymbol',sps);
phaseFreqOffset = comm.PhaseFrequencyOffset(...
    'FrequencyOffset',10,...
    'PhaseOffset',0,...
    'SampleRate',fs);


plotspec(txSig, 1/fs);
title("Before Freq Offset")

% Apply channel objects
freqOffsetSig = phaseFreqOffset(txSig);
figure;
plotspec(freqOffsetSig, 1/fs);

rxSig = channel(txSig);         % Apply AWGN
% rxSig = txSig;

% scatterplot(rxSig);

% plotspec(rxSig, 1/fs);
% title("After Freq Offset");

% plotspec(rxSig, 1/fs);

%% Receiver
% constdiagram(rxSig)
% release(constdiagram);

downconverted = downconvert(rxSig);
% downconverted=rxSig.';

% Carrier Recovery
coarseSync = comm.CoarseFrequencyCompensator('Modulation','BPSK','FrequencyResolution',1,'SampleRate',fs*sps);
fineSync = comm.CarrierSynchronizer('DampingFactor',0.4, ...
    'NormalizedLoopBandwidth',0.001, ...
    'SamplesPerSymbol',sps, ...
    'Modulation','BPSK');

syncCoarse = coarseSync(downconverted.');
rxData = fineSync(syncCoarse);
% rxData = downconverted;

scatterplot(rxData);
title("After Freq Recovery");

rxFilt = upfirdn(rxData, rrcFilter, 1, sps);
rxMatchedData = rxFilt(span+1:end-span);
% rxMatchedData = rxfilter(rxData);
% delay = txfilter.FilterSpanInSymbols;
% rxMatchedData = rxMatchedData(delay+1:end);

rxDemod = Demodulation(rxMatchedData);

% zero_array = zeros(1, length(data)-length(rxDemod));
% rxDemod = [rxDemod zero_array];

%% Analysis
%  BER
[number, ratio] = biterr(data, rxDemod.');
disp("BER: " + ratio + " Number: " + number);

% constdiagram(rxMatchedData);
