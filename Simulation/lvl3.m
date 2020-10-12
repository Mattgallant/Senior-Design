%% LVL 3
%  Implemented - Input Data, TXT-To-Bitstream, Mapping, Channel Encoding, SRRC, Upconversion, 
%  Downconversion, Match Filtering, Decoding, Demapping, Bitstream-To-TXT

%  Not yet implemented - Timing Offset, Carrier Offset, Training detection/injection,
%  AGC, Channel estimation/equalization

Fs = 44100;
%% Transmitter
%  Input Data
file_pointer= fopen("lorem.txt"); 
read_length_characters = 2001; 

%  TXT-To-Bitstream
[source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);

%  Channel Encoding
encoded_bits = turbo_encoding(sendable_bits.');

%  Constellation Mapping
modulated_bits = BPSK_mapping(encoded_bits);

% figure;
% plottf(modulated_bits,1/Fs);
% title("Modulated Bits")

%  SRRC Filtering
rolloff = 0.25;
span = 10;
sps = 6;
M = 2;
k = log2(M);

rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
pulseShaped = upfirdn(modulated_bits, rrcFilter, sps);

% figure;
% plottf(pulseShaped,1/Fs);
% title("Pulse Shaped")

%Upconversion
txSig = upconvert(pulseShaped);

% figure;
% plottf(txSig,1/Fs);
% title("Upconverted Signal")

%% Channel
EbNo = 7;
snr = EbNo + 10*log10(k) - 10*log10(sps);
rxSig = awgn(txSig, snr, 'measured');
% rxSig = txSig;
%% Reciever

%Downconversion
downconverted = downconvert(rxSig);

% figure;
% plottf(downconverted,1/Fs);
% title("Downconverted")

%  Match (SRRC) Filtering
rxFilt = upfirdn(downconverted, rrcFilter, 1, sps);
match_filtered_signal = rxFilt(span+1:end-span);

% figure;
% plottf(match_filtered_signal,1/Fs);
% title("Match Filtered")

%  Constellation DeMapping
demodulated_bits =  Demodulation(match_filtered_signal);
demodulated_bits = demodulated_bits(:);

%  Channel Decoding

decoded_bits = TurboDecoding(demodulated_bits);

%  Bitstream-To-TXT
%text = Bitstream_to_Text(decoded_bits);


%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio);

