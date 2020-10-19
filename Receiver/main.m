% main script for the receiver. All receiver functions should be
% plugged into this file.
% Subteam: Joseph, Austin, Phat & Carolyn
    
%% Input from microphone (Matt)
% Mic_to_Receiver(Seconds to record)
    rxSig = Mic_to_Receiver(2); % Record for 5 seconds
    disp("Recorded : " + length(rxSig) + " bits")
    
%% Downconversion
    downconverted = downconvert(rxSig);
    
%% Matched Filter (Neel)
% MatchedFilter - takes in: equalized_signal as the result of the previous
% module
    %Filter properties - Make sure these match transmitter values 
    rolloff = 0.25;
    span = 10;
    sps = 6;
    M = 2;
    k = log2(M);
    
    % Create matched filter
    rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');

    rxFilt = filter(rrcFilter,1, downconverted);
    delay = ceil(length((rrcFilter - 1) / 2));
    match_filtered_signal = [rxFilt(delay:end)];
    
%%  Carrier Frequency Offset Recovery
    rxCFO = CarrierFrequencyOffset(match_filtered_signal);

%% Timing Offset Recovery
    rxSync = TimingOffset(rxCFO, sps).';
    
%% Training sequence detection (Carolyn)
% GolayDetection()
    sequence_length = 128; % Length established in main transmitter script
    [Ga,~] = wlanGolaySequence(sequence_length);
    trainingSequence = reshape(Ga, [1,sequence_length]);
    
    [retrieved_sequence, retrieved_data] = GolayDetection(rxSync, 128, training_sequence);
    
%% Automatic Gain Control (Phat) - current method relies on training sequence
% AGC_KnownFunction(signal to be equalized, known signal)
    estimatedGain = AGC_KnownFunction(retrieved_sequence, training_sequence);
    gainCorrectedSignal = retrieved_data./estimatedGain;
    gainCorrectedSequence = retrieved_sequence./estimatedGain;

%% Channel Estimation and Equalization (Joseph) TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% ChannelEqualization()
%    [equalized_signal,~] = ChannelEqualization(gainCorrectedSignal, gainCorrectedSequence, trainingSequence);

%% Demodulation (Jaino)
%     demodulatedBits = Demodulation(equalized_signal);
    demodulatedBits =  Demodulation(gainCorrectedSequence);

%% Turbo Decoding (Joseph)
    decoded_bits = TurboDecoding(demodulatedBits);

    
    
%% Convert Bits to Text (Jaino)
% Bitstream_to_Text()
    % Cutoff last bits to make multiple of 7.
    remainder = mod(length(decoded_bits), 7 );
    decoded_bits = decoded_bits(1:(length(decoded_bits)-remainder), :);

    text = Bitstream_to_Text(decoded_bits.');
    disp(text)
    
%% Bit Error Rate Calculations
% [number, ratio] = biterr(sendable_bits(:), decoded_bits);
% disp(number);
