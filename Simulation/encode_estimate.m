%Initialize the Equalizer object, to tune it, change the taps integers

M = 2;
numTrainSymbols = 32;
numDataSymbols = 200;
SNR = 20;
rng default;

% Generate Bits
bits = randi([0 M-1],numDataSymbols,1);

% Encode Bits
% trellis = poly2trellis(4,[13 15 17],13);
% interleaver_indicies = randperm(length(bits));    
% turboEncoder = comm.TurboEncoder(trellis, interleaver_indicies);
% encoded_bits = turboEncoder(bits);
encoded_bits = turbo_encoding(bits);

% Modulate to Symbols
bpskmod = comm.BPSKModulator;
dataSym = bpskmod(encoded_bits);

% Inject Training Sequence
% [Ga,~] = wlanGolaySequence(numTrainSymbols);
% trainingSymbols = reshape(Ga, [1,numTrainSymbols]);
% trainingSymbols = complex(trainingSymbols');
% 
% % Pass through filter (represents transmitting)
% chCo=[1 0.1 -0.1]; 
% packet = [trainingSymbols; dataSym];
% channel = 1;
% % rx = packet;
% % rx = awgn(packet, 1);
% rx = filter(chCo,1,packet);
% 
% % Channel Estimate
% dfeq = comm.DecisionFeedbackEqualizer('Algorithm','LMS','NumForwardTaps',4,'NumFeedbackTaps',3,'ReferenceTap',3,'StepSize',0.001);
% 
% numPkts = 10;
% for ii = 1:numPkts
%     [rx_equalized, err] = dfeq(rx,trainingSymbols);
% end
% [rx_equalized, err] = dfeq(rx,trainingSymbols);
% 
% rx_equalized = rx_equalized(length(trainingSymbols) + 1 : end);

% Demodulate
bpskdemod = comm.BPSKDemodulator;
rx_data = bpskdemod(dataSym);

% Decode
% original_length = (length(rx_data) - 18)/5;
% interleaver_indicies = randperm(original_length);
% turbodec = comm.TurboDecoder(trellis, interleaver_indicies, 4);

% rx_bits = turbodec(rx_data);
rx_bits = TurboDecoding(rx_data.');

% rx_bits = rx_data;

% Plot results
% error = rx_bits - bits;
% bit_error_rate = nnz(error)/length(bits);

% disp(bit_error_rate);

%  BER
[number, ratio] = biterr(rx_bits, bits);
disp("BER: " + ratio + " Number: " + number);


scatter(complex([1:length(error)])', error)
ylim([0 1])
title(['Error in Recieved Signal']);
xlabel('Symbols');
ylabel('Error Magnitude');
grid on;