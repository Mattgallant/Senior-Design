% Main script for the transmitter. All transmitter functions should be
% plugged into this file.
% Subteam: Matt, Jaino & Neel


%% Input Data (Text File, String)
filePointer= fopen('alice_in_wonderland.txt');
read_length = 1000000;


%% Bitstream Conversion (Jaino)
% text_to_bitstream
[sourceCharacters, sendableBits] = text_to_bitstream(filePointer, read_length);


%% Channel Encoding (Joseph) 
% turbo_encoding


%% Constellation Mapping (Jaino)
% BPSK_mapping


%% Training Sequence Injection (Carolyn)
% golay_injection


%% Pulse Shaping & Upsampling(Neel)
% upsample_and_filter, srrc_filter


%% Upconversion (Matt)
% upconvert
    wave = randi(10, 1, 5*44100);
    upconverted_wave = upconvert(wave);

%% Output to speaker (Matt)
% transmitter_to_speaker
    transmitter_to_speaker(upconverted_wave);