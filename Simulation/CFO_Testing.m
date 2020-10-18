%% LVL 0
%  Input Data, TXT-To-Bitstream, Bitstream-to-TXT
Fs = 44100;
%% Input Data (Text File, String)
    filePtr= fopen("lorem.txt");   %Open file to read from
    fileReadLength = 2000;

%% Transmitter
    % Text to bitstream
    [~, sendableBits] = text_to_bitstream(filePtr, fileReadLength);
    scatterplot(sendableBits)
    
    % Channel Encoding
    %encodedBits = turbo_encoding(sendableBits.');
    
    % Modulate
    modBits = BPSK_mapping(sendableBits);
    scatterplot(modBits)

%% Channel
    % Simulate noise and other interference factors here
    
    %Phase offset of 45 degrees and frequency offset of 1 Khz
    %pfo = comm.PhaseFrequencyOffset('PhaseOffset',45, ...
    %'FrequencyOffset',1e4,'SampleRate',1e6);
    %modBitsOffset = pfo(modBits);
    %scatterplot(modBitsOffset)
    
    % AWGN
    sps = 6;
    M = 2;
    k = log2(M);
    channel = comm.AWGNChannel('EbNo',30,'BitsPerSymbol',k,'SamplesPerSymbol',sps);
    noisySignal = channel(modBits);
    plotspec(noisySignal, 1/Fs);
    title('Transmitted signal w/ AWGN')
    
    % How do you simulate cfo? x[n]*e^(j*2*pi*(delta f/fs)*n
    % x[n] is our signal, deltaf/fs is ratio, n is sample length of signal
    
    ratio = 0.0001;
    cfo = noisySignal.*exp(-j*2*pi*ratio*(0:length(noisySignal)-1));
    scatterplot(cfo)
    plotspec(cfo, 1/Fs);
    title('Transmitted signal w/ AWGN and CFO');
    
    
%% Receiver
    % CFO compensation
    compSignal = CarrierFrequencyOffset(cfo);
    scatterplot(compSignal)
    
    % Demodulate
    demodBits = Demodulation(compSignal);
    demodBits = demodBits(:);
    scatterplot(demodBits)
    % Decoding
    %decodedBits = TurboDecoding(demodBits);
    
    % Bitstream to text
    text = Bitstream_to_Text(demodBits);
    disp(text)
    
%% Results
[number, result] = biterr(sendableBits(:), demodBits);
disp(result);
