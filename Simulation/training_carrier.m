% Tests the ability of the system to detect training sequence when
% upconversion and downconversion is performed on the signal.
sequenceLength = 128;
length = 1000;
Fs = 44100;

%% Transmitter
data = randi([0 1],1000, 1);
[dataWithTraining, trainingSequence] = golay_injection(data.', sequenceLength);

% Perform upconversion
upconvertedData = upconvert(dataWithTraining);

%% Channel
% snr = -10;
% rxSig = awgn(dataWithTraining, snr);

%% Receiver

% Downconversion
downconvertedData = downconvert(upconvertedData);
% figure;
% plottf(downconvertedData,1/Fs)
% title("Downconverted, no LPF")

% h = firlpf(49, 4200, 5000, Fs);
% filtered = filter(h,1,downconvertedData);
% figure;
% plottf(filtered,1/Fs)
% title("Downconverted, w/ LPF")

% Detection
% [receivedSequence, receivedData] = GolayDetection(upconvertedData, sequenceLength, trainingSequence);

%% Analysis
% disp("Variance of the noisy signal is: " + var(rxSig));
% %  BER
% [number, ratio] = biterr(data.', receivedData);
% disp("BER: " + ratio);

%% Debug
figure;
plottf(dataWithTraining, 1/Fs);
title("Vanilla Data");

figure;
plottf(upconvertedData,1/Fs);
title("Upconverted Data")

figure;
plottf(upconvertedData,1/Fs);
title("Downconverted Data")