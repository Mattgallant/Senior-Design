% Testing Turbo Encoding/Decoding
% Trying to resolve issue with interleaver indices

%% Input Data (Text File, String)
    file_pointer= fopen("lorem.txt"); %Open file to read from
    read_length_characters = 5000; % DO NOT CHANGE THIS FOR NOW, INTERLEAVER INDICIES NEEDS 2000

%% Bitstream Conversion (Jaino)
% text_to_bitstream
    [source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);
    [text] = bitstream_to_text(sendable_bits);
   
%% Channel Encoding (Joseph) 
% turbo_encoding
   encoded_bits = turbo_encoding(sendable_bits.');
   
%% SENT
%% Turbo Decoding (Joseph)
    decoded_bits = TurboDecoding(encoded_bits);

%% Analysis

%  BER
[~, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio);

% Interleaver
% [numberm ratio] = biterr(interleaver_indicies_dec, interleaver_indicies_enc);
% disp("Difference in Interleaver: " + ratio);
