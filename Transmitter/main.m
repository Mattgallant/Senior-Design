% Main script for the transmitter. All transmitter functions should be
% plugged into this file.
% Subteam: Matt, Jaino & Neel

%% Input Data (Text File, String)
    file_pointer= fopen("lorem.txt"); %Open file to read from
    read_length = 6144;

%% Bitstream Conversion (Jaino)
% text_to_bitstream
    [source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length);
    disp(sendable_bits) %Currently a row vector

%% Channel Encoding (Joseph) 
% turbo_encoding
    encoded_bits = turbo_encoding(sendable_bits);
   disp(encoded_bits); %Currently a col vector

%% Constellation Mapping (Jaino)
% BPSK_mapping
    modulated_bits = BPSK_mapping(encoded_bits);
    disp(modulated_bits); %Currently a row vector

%% Training Sequence Injection (Carolyn)
% golay_injection

%% Pulse Shaping & Upsampling(Neel)
% upsample_and_filter, srrc_filter

%% Upconversion (Matt)
% upconvert
    %wave = randi(10, 1, 5*44100);       % For testing purposes
    upconverted_wave = upconvert(real(modulated_bits));

%% Output to speaker (Matt)
% transmitter_to_speaker
    transmitter_to_speaker(upconverted_wave);
   