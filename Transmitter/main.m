% Main script for the transmitter. All transmitter functions should be
% plugged into this file.
% Subteam: Matt, Jaino & Neel

%% Input Data (Text File, String)
    file_pointer= fopen("lorem.txt");   %Open file to read from
    read_length_characters = 200;

%% Bitstream Conversion (Jaino)
% text_to_bitstream
    [source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);
%     [text] = bitstream_to_text(sendable_bits);
   
%% Channel Encoding (Joseph) 
% turbo_encoding
   encoded_bits = turbo_encoding(sendable_bits.');

%% Constellation Mapping (Jaino)
% BPSK_mapping
    modulated_bits = BPSK_mapping(encoded_bits);

%% Training Sequence Injection (Carolyn)
% golay_injection
    [bitstream_with_injection, training_sequence] =  golay_injection(modulated_bits, 128);

%% Pulse Shaping & Upsampling(Neel)
% upsample_and_filter, srrc_filter
%   Filter properties
    rolloff = 0.25;
    span = 10;
    sps = 6;
    M = 2;
    k = log2(M);

    rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
    pulseShaped = upfirdn(real(bitstream_with_injection), rrcFilter, sps);
    
%% Upconversion (Matt)
% upconvert
    txSig = upconvert(real(pulseShaped));
    
% figure;
% plottf(txSig, 1/44100);
% title('Received Sound')

%% Output to speaker (Matt)
% transmitter_to_speaker
    disp("Sound playing for: " + length(txSig)/44100 + " seconds");
    transmitter_to_speaker(1*txSig);
    
%     audiowrite("test.mp4",txSig,44100)
   