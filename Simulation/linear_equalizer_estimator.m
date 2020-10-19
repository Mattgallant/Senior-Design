close all;
clear all;

%% Transmitter
%  Input Data
file_pointer= fopen("lorem.txt"); 
read_length_characters = 2000; 

%  TXT-To-Bitstream
[source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);

%  Channel Encoding
encoded_bits = turbo_encoding(sendable_bits.');

%  Constellation Mapping
modulated_bits = BPSK_mapping(encoded_bits);

% Golay Sequence Injection
[bitstream_with_injection, training_sequence] =  golay_injection(modulated_bits, 128);
training_sequence = complex(training_sequence');

%% Channel
chtaps = [1 0.5*exp(1i*pi/6) 0.1*exp(-1i*pi/8)];
sps = 6;
M = 2;
k = log2(M);
EbNo = 5;
snr = EbNo + 10*log10(k) - 10*log10(sps);
noisySig = awgn(filter(chtaps, 1, bitstream_with_injection), 25, 'measured')';

eq = comm.LinearEqualizer('Algorithm','LMS','ReferenceTap',1,'StepSize',0.001);
% Estimate the channel and equalize with each step, each packet you pass
% will train the equalizer object and update its weights
numPkts = 25;
for ii = 1:numPkts
    [rx_equalized, err] = eq(noisySig, training_sequence);
end
[rx_equalized, err] = eq(noisySig,training_sequence);

% isolate the data from the training sequence
rx_equalized = rx_equalized(length(training_sequence) + 1 : end);

%  Constellation DeMapping
demodulated_bits =  Demodulation(rx_equalized);
demodulated_bits = demodulated_bits(:);

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits.');

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);