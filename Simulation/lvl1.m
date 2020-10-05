%% LVL 1
%  Input Data, TXT-To-Bitstream, Mapping, Channel Encoding, Decoding, Demapping,
%  Bitstream-To-TXT

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

%% Channel


%% Reciever

%  Constellation DeMapping

demodulated_bits =  Demodulation(modulated_bits);
demodulated_bits = demodulated_bits(:);

%  Channel Decoding

decoded_bits = TurboDecoding(demodulated_bits);

%  Bitstream-To-TXT

text = Bitstream_to_Text(decoded_bits);

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp(number);

