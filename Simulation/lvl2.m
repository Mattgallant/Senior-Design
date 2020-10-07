%% LVL 2
%  Input Data, TXT-To-Bitstream, Mapping, Channel Encoding, SRRC, Match Filtering, 
%  Decoding, Demapping, Bitstream-To-TXT

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

%  SRRC Filtering

oversampling_factor = 4; 
span = 10; 
rolloff = .1; 
dataRate = 500; 
[pulse_shaped_signal] = srrc_filter(modulated_bits,span,rolloff,oversampling_factor,dataRate);

%% Channel


%% Reciever

%  Match (SRRC) Filtering (NOT WORKING)

[match_filtered_signal] = srrc_filter(pulse_shaped_signal,span,rolloff,oversampling_factor,dataRate);
length(match_filtered_signal)
%  Constellation DeMapping

demodulated_bits =  Demodulation(match_filtered_signal);
demodulated_bits = demodulated_bits(:);

%  Channel Decoding

decoded_bits = TurboDecoding(demodulated_bits);

%  Bitstream-To-TXT

text = Bitstream_to_Text(decoded_bits);

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp(number);

