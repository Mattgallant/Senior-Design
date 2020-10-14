Fs = 44100;
inputLength = 500;

%% Transmitter

% Generate Bits
bits = randi([0 1],inputLength,1);

% BPSK Modulation
modulatedBits = real(BPSK_mapping(bits));

figure;
plottf(modulatedBits,1/Fs);
title("Modulated Bits")

%Upconversion
txSig = upconvert(modulatedBits);

figure;
plottf(txSig,1/Fs);
title("Upconverted Bits")

%% Channel
rxSig = txSig;
% downconvertedBits = modulatedBits;

%% Receiver
% Downconversion
downconvertedBits = downconvert(rxSig);

% Demodulation
demodulatedBits =  Demodulation(downconvertedBits).';

%% Analysis
%  BER
[number, ratio] = biterr(bits, demodulatedBits);
disp("BER: " + ratio + " Number: " + number);
