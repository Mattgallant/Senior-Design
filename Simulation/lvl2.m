%% LVL 2
%  Input Data, TXT-To-Bitstream, Mapping, Channel Encoding, SRRC, Match Filtering, 
%  Decoding, Demapping, Bitstream-To-TXT

%% Transmitter
%  Input Data
file_pointer= fopen("lorem.txt"); 
read_length_characters = 100; 

%  TXT-To-Bitstream
[source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);
length(sendable_bits);

%  Channel Encoding
encoded_bits = turbo_encoding(sendable_bits.');
length(encoded_bits);

%  Constellation Mapping
modulated_bits = BPSK_mapping(encoded_bits);

%  SRRC Filtering
rolloff = 0.25;
span = 10;
sps = 6;
M = 2;
k = log2(M);

rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');

txSig = upfirdn(modulated_bits, rrcFilter, sps);

%% Channel;
figure;
t = 1:length(txSig);
scatter(t, txSig);

EbNo = -2;
snr = EbNo + 10*log10(k) - 10*log10(sps);
disp(snr)
rxSig = awgn(txSig, snr);
figure;
t = 1:length(rxSig);
scatter(t, rxSig);


%% Reciever
%  Match (SRRC) Filtering (NOT WORKING)
rxFilt = upfirdn(rxSig, rrcFilter, 1, sps);
match_filtered_signal = rxFilt(span+1:end-span);

length(match_filtered_signal);
%  Constellation DeMapping

demodulated_bits =  Demodulation(match_filtered_signal);
demodulated_bits = demodulated_bits(:);

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits);

length(decoded_bits);
%  Bitstream-To-TXT
%text = Bitstream_to_Text(decoded_bits);

%% Analysis
%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp(ratio);

