close all;
clear all;

% channel and message parameters
M = 2;
chCo=[1 0.1 -0.1];
channel = 1;
numTrainSymbols = 128;
numDataSymbols = 18000;
SNR = 20;
rng default;

% Generate Bits
bits = randi([0 M-1],numDataSymbols,1);

% Encode Bits
% define the turbo encoder and encode the bitstring
trellis = poly2trellis(4,[13 15 17],13);
interleaver_indicies = randperm(length(bits));    
turboEncoder = comm.TurboEncoder(trellis, interleaver_indicies);

encoded_bits = turboEncoder(bits);

%ebits = lteTurboEncode(bits); % LTE library works well but only for 6144 bits

% Modulate to Symbols
% Modulate the data using BPSK
bpskmod = comm.BPSKModulator;
dataSym = bpskmod(encoded_bits);

% Inject Training Sequence
% Create the true training sequence for the message
[Ga,~] = wlanGolaySequence(numTrainSymbols);
trainingSymbols = reshape(Ga, [1,numTrainSymbols]);
trainingSymbols = complex(trainingSymbols');

% Pass through filter (represents transmitting)
% pack the modulate and encoded data with the true training symbols
packet = [trainingSymbols; dataSym];

% Add noise to the packet as it would experience being transmitted through a channel
%rx = packet;
chtaps = [1 0.5*exp(1i*pi/6) 0.1*exp(-1i*pi/8)];
rx = awgn(filter(chtaps, 1, packet), 25, 'measured');

% plot the noise signal
scatterplot(rx)
title(['Noisy Signal']);
grid on;

% Channel Estimate
%Initialize the Equalizer object, to tune it, change the taps integers
dfeq = comm.DecisionFeedbackEqualizer('Algorithm','LMS','NumForwardTaps',4,'NumFeedbackTaps',3,'ReferenceTap',3,'StepSize',0.001);

% Estimate the channel and equalize with each step, each packet you pass
% will train the equalizer object and update its weights
numPkts = 25;
for ii = 1:numPkts
    [rx_equalized, err] = dfeq(rx, trainingSymbols);
end
[rx_equalized, err] = dfeq(rx,trainingSymbols);

% isolate the data from the training sequence
rx_equalized = rx_equalized(length(trainingSymbols) + 1 : end);

% plot equalized signal
scatterplot(rx_equalized)
title(['Equalized Signal']);
grid on;

% Demodulate
bpskdemod = comm.BPSKDemodulator;
rx_data = bpskdemod(rx_equalized);

% Decode
original_length = (length(rx_data) - 18)/5;
interleaver_indicies = randperm(original_length);
turbodec = comm.TurboDecoder(trellis, interleaver_indicies, 4);

rx_bits = turbodec(rx_data);

% Plot results
error = real(rx_bits - bits);
scatterplot(error)
title(['Error in Recieved Signal']);
grid on;

%  BER
[number, ratio] = biterr(rx_bits, bits);
disp("BER: " + ratio + " Number: " + number);