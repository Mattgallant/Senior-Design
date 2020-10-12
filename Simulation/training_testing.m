% This script tests the ability of training sequence detection in various
% scenarios.
sequenceLength = 128;
length = 1000;

%% Transmitter
data = randi([0 1],1000, 1);
[dataWithTraining, trainingSequence] = golay_injection(data.', sequenceLength);


%% Channel
% Add a bunch of random bits at the front to simulate timing offset
dataWithTraining = [randi([0 1],1000, 1).' dataWithTraining]; 

% Training should now be at 1001-1128

snr = 10;
rxSig = awgn(dataWithTraining, snr);

%% Receiver
[receivedSequence, receivedData] = GolayDetection(rxSig, trainingSequence);

%% Analysis
disp("Variance of the noisy signal is: " + var(rxSig));
% %  BER
% [number, ratio] = biterr(data.', receivedData);
% disp("BER: " + ratio);