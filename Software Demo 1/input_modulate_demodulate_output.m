% Main script to show proper file input and modulation/demodulation

%% Input Data File (Text File, String)
    file_pointer= fopen("lorem.txt"); 
    read_length_characters = 11; 

%% Read File and Bitstream Conversion
    [source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);
    
    fprintf('\n')
    disp("Text Characters")
    disp(source_characters)
    
    fprintf('\n')
    disp("Text Characters As Bits")
    disp(sendable_bits) 

%% Constellation Mapping
% BPSK_mapping
    modulated_bits = BPSK_mapping(sendable_bits);
    fprintf('\n')
    disp("Bits Modulated Using BPSK Mapping")
    disp(modulated_bits); 
    
%% Constellation Mapping Demodulation
    demodulated_bits = Demodulation(modulated_bits);
    fprintf('\n')
    disp("BPSK Modulated Bits Demodulated Using BPSK Mapping")
    disp(demodulated_bits); 
    
%% Revert Bitstream Conversion
    [text] = bitstream_to_text(sendable_bits);
    fprintf('\n')
    disp("Demodulated Bits Converted To Text")
    disp(text); 