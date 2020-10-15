% CFO Demo
close all
clc
clear

n = 1000; % Length of message
msg = randi([0,1],n,1); % Random message of bits
bpskMod = comm.BPSKModulator;   % BPSK mod object
% bpskMod.PhaseOffset = pi/4;     % Set phase offset

pfo = comm.PhaseFrequencyOffset('PhaseOffset',45, ...
    'FrequencyOffset',1e6);
modData = bpskMod(msg);         % Modulate message w/ offset

modSigOffset = pfo(modData);
snr = 3;    % Signal-to-Noise Ratio
% rxSig = awgn(modSigOffset,snr);   % Add white noise

t = (1:length(modData))';
phaseOff = ( 2*pi*.9*t);
freqShifted = modData.*exp(1j*phaseOff);


plot(freqShifted);

scatterplot(freqShifted(1:end));
title('Constellation with CFO')

outSig = CarrierFrequencyOffset(freqShifted');
disp(outSig)
scatterplot(outSig);
title('Constellation after Carrier Recovery')



