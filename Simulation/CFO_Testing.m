%% LVL 0
%  Input Data, TXT-To-Bitstream, Bitstream-to-TXT

%% Input Data (Text File, String)
    filePtr= fopen("lorem.txt");   %Open file to read from
    fileReadLength = 2000;

%% Transmitter
    % Text to bitstream
    [~, sendableBits] = text_to_bitstream(filePtr, fileReadLength);
    
    % Channel Encoding
    encodedBits = turbo_encoding(sendableBits.');
    
    % Modulate
    modBits = BPSK_mapping(encodedBits);
   

%% Channel
    % Simulate noise and other interference factors here
    
    % Phase offset of 45 degrees and frequency offset of 1 Khz
    pfo = comm.PhaseFrequencyOffset('PhaseOffset',45, ...
    'FrequencyOffset',1e4,'SampleRate',1e6);
    modBitsOffset = pfo(modBits);
    
%% Receiver
    % CFO compensation
    compSignal = CarrierFrequencyOffset(modBitsOffset);
    
    % Demodulate
    demodBits = Demodulation(compSignal);
    demodBits = demodBits(:);
    
    % Decoding
    decodedBits = TurboDecoding(demodBits);
    
    % Bitstream to text
    text = Bitstream_to_Text(decodedBits);
    disp(text)
    
%% Results
[number, ratio] = biterr(sendableBits(:), decodedBits);
disp(ratio);
