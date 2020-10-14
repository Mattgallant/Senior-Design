%% LVL 4
%  Implemented - Input Data, TXT-To-Bitstream, Consetellation Mapping, 
%  Golay Injection, Channel Encoding, SRRC, Match Filtering,
%  Golay Sequence Detection, AGC,  Decoding, Demapping, Bitstream-To-TXT

%  Not yet implemented - Timing Offset, Carrier Offset, Channel estimation/equalization
%  Downconversion, Upconversion

Fs = 44100;
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

%  SRRC Filtering
rolloff = 0.25;
span = 10;
sps = 6;
M = 2;
k = log2(M);

rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
pulseShaped = upfirdn(real(bitstream_with_injection), rrcFilter, sps);

%Upconversion
%txSig = upconvert(pulseShaped);
txSig = pulseShaped;

%% Channel
garbage = [randi([0 1],2112, 1).' txSig]; 
EbNo = 5;
snr = EbNo + 10*log10(k) - 10*log10(sps);
disp("SNR: " + snr)
rxSig = awgn(garbage, snr, 'measured');
% rxSig = garbage;
%% Reciever

%Downconversion
%downconverted = downconvert(rxSig);
downconverted = rxSig;

%  Match (SRRC) Filtering
rxFilt = upfirdn(downconverted, rrcFilter, 1, sps);
match_filtered_signal = rxFilt(span+1:end-span);

% Golay Sequence Detection
[retrieved_sequence, retrieved_data] = GolayDetection(match_filtered_signal, 128, training_sequence);
disp("Length of retrieved_data: " + length(retrieved_data));

scatterplot(retrieved_data);
title('Retrieved Signal');

% Automatic Gain Control
estimatedGain = AGC_KnownFunction(retrieved_sequence, training_sequence);
gainCorrectedSignal = retrieved_data./estimatedGain;
gainCorrectedSequence = retrieved_sequence./estimatedGain;

scatterplot(gainCorrectedSignal);
title('Gain Corrected Signal');

%  Constellation DeMapping
demodulated_bits =  Demodulation(gainCorrectedSignal);
demodulated_bits = demodulated_bits(:);

zero_array = zeros(1, length(modulated_bits)-length(demodulated_bits));
demodulated_bits = [demodulated_bits.' zero_array];

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits.');

%  Bitstream-To-TXT
text = Bitstream_to_Text(decoded_bits);

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);
