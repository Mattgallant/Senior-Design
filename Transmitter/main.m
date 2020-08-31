% Main script for the transmitter. All transmitter functions should be
% plugged into this file.
% Subteam: Matt, Jaino & Neel


%% Input Data (Text File, String)


%% Bitstream Conversion (Jaino)
% text_to_bitstream


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
    wave = [1, 2, 3, 4];
    upconverted_wave = upconvert(wave);

%% Output to speaker (Matt)
% transmitter_to_speaker
    transmitter_to_speaker(upconverted_wave);