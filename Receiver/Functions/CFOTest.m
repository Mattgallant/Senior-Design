% CFO Demo
close all
clc
clear

n = 500; % Length of message
msg = randi([0,1],n,1); % Random message of bits
bpskMod = comm.BPSKModulator;   % BPSK mod object
bpskMod.PhaseOffset = pi/4;    % Set phase offset
modData = bpskMod(msg);     % Modulate message w/ offset

snr = 5;    % Signal-to-Noise Ratio
rxSig = awgn(modData,snr);   % Add white noise
scatterplot(rxSig(1:end));
title('Constellation with CFO of \pi/4')

[outSig, phaseErr] = CarrierFrequencyOffset(rxSig);
disp(phaseErr)
scatterplot(outSig(1:end));
title('Constellation after Carrier Recovery')



