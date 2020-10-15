
%% LVL 6
%  Implemented - Input Data, TXT-To-Bitstream, Consetellation Mapping, 
%  Golay Injection, Channel Encoding, SRRC, Match Filtering, Timing Offset,
%  Golay Sequence Detection, Upconversion, Downconversion, AGC, Decoding, Demapping, Bitstream-To-TXT

%  Not yet implemented - Carrier Offset, Channel estimation/equalization

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
txSig = upconvert(pulseShaped);
%txSig = pulseShaped;

%% Channel
garbage = [zeros(1, 500) txSig];  
EbNo = 5;
snr = EbNo + 10*log10(k) - 10*log10(sps);
disp("SNR: " + snr)
gainFactor = 1/2;
garbage = garbage*gainFactor;
rxSig = awgn(garbage, snr, 'measured');

%% Reciever

%Downconversion
downconverted = downconvert(rxSig);

%  Match (SRRC) Filtering
rxFilt = filter(rrcFilter,1, downconverted);
delay = ceil(length((rrcFilter - 1) / 2));
match_filtered_signal = [rxFilt(delay:end)];

% Timing offset
rxSync = TimingOffset(match_filtered_signal.', sps).';

% Golay Sequence Detection
[retrieved_sequence, retrieved_data] = GolayDetection(rxSync, 128, training_sequence);
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

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits.');

%  Bitstream-To-TXT
text = Bitstream_to_Text(decoded_bits);

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);
