%% LVL 5
%  Implemented - Input Data, TXT-To-Bitstream, Mapping, Training Injection,
%  Channel Encoding, SRRC, Upconversion, Downconversion, Match Filtering,
%  Training Sequence Detection, Decoding, Demapping, Bitstream-To-TXT

%  Not yet implemented - Timing Offset, Carrier Offset, AGC, Channel estimation/equalization

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
modulated_bits = real(BPSK_mapping(encoded_bits));

% Training Sequence Injection (Carolyn)
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

%% Channel 
EbNo = 10;
snr = EbNo + 10*log10(k) - 10*log10(sps);
disp("SNR: " + snr)

garbage = [zeros(1, 500) txSig];            % Add garbage at front
rxSig = awgn(garbage, snr, 'measured');     % Add noise
% rxSig = awgn(txSig, snr, 'measured');
% rxSig = garbage;

%% Reciever

% Downconversion
downconverted = downconvert(rxSig);

%  Match (SRRC) Filtering
rxFilt = filter(rrcFilter,1, downconverted);
delay = ceil(length((rrcFilter - 1) / 2));
match_filtered_signal = [rxFilt(delay:end)];

% Timing offset
rxSync = TimingOffset(match_filtered_signal.', sps).';

% Training sequence detection (Carolyn)
[retrieved_sequence, retrieved_data] = GolayDetection(real(rxSync), 128, training_sequence);

%  Constellation DeMapping
demodulated_bits =  Demodulation(retrieved_data);
demodulated_bits = demodulated_bits(:);

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits.');

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);

%  Bitstream-To-TXT
% text = Bitstream_to_Text(decoded_bits);
% disp(text);

%% DEBUG
% figure;
% plottf(pulseShaped,1/Fs);
% title("Pulse Shaped")

% figure;
% plottf(txSig,1/Fs);
% title("Upconverted Signal")

% figure;
% plottf(downconverted,1/Fs);
% title("Downconverted")

% figure;
% plottf(match_filtered_signal,1/Fs);
% title("Match Filtered")

% prbdet = comm.PreambleDetector(training_sequence.');
% prbdet.Threshold = 50;
% [idx,detmet] = prbdet(match_filtered_signal.');

% Checking the training sequence
% demodulated_training_rx = Demodulation(retrieved_sequence);
% demodulated_training_tx = Demodulation(training_sequence);
% [number, ratio] = biterr(demodulated_training_rx, demodulated_training_tx);
% disp("Training BER: " + ratio + " Number: " + number);
