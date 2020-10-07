% main script for the receiver. All receiver functions should be
% plugged into this file.
% Subteam: Joseph, Austin, Phat & Carolyn

%% Initialization
% Known golay training sequence we are working with
    sequence_length = 128; % Length established in main transmitter script
    [Ga,~] = wlanGolaySequence(sequence_length);
    trainingSequence = reshape(Ga, [1,sequence_length]);
    
%% Input from microphone (Matt)
% Mic_to_Receiver(Seconds to record)
    binary_input = Mic_to_Receiver(1); % Record for 5 seconds
    disp("Recorded : " + length(binary_input) + " bits")

%% Training sequence detection (Carolyn)
% GolayDetection()
    [retrieved_sequence, retrieved_data] = GolayDetection(binary_input, sequence_length, trainingSequence);
    
%% Timing Offset (Phat) - TBD after detection implementation
% TimingOffset() 
% **Timing Offset is resolved through training sequence detection**

%% Carrier Frequency Offset (Austin)
% CarrierFrequencyOffset()
[receivedSignal] = CarrierFrequencyOffset(double(retrieved_data));
[receivedSequence] = CarrierFrequencyOffset(double(retrieved_sequence));

%% Automatic Gain Control (Phat) - current method relies on training sequence
% AGC_KnownFunction(signal to be equalized, known signal)
    estimatedGain = AGC_KnownFunction(receivedSignal, trainingSequence);
    gainCorrectedSignal = receivedSignal./estimatedGain;
    gainCorrectedSequence = receivedSequence./estimatedGain;

%% Channel Estimation and Equalization (Joseph)
% ChannelEqualization()
   [equalized_signal,~] = ChannelEqualization(gainCorrectedSignal, gainCorrectedSequence, trainingSequence);

%% Matched Filter (Neel)
% MatchedFilter - takes in: equalized_signal as the result of the previous
% module

%Filter properties - Make sure these match transmitter values 
oversampling_factor = 4; % Number of samples per symbol (oversampling factor)
span = 10; % Filter length in symbols
rolloff = .1; % Filter rolloff factor
dataRate = 500; %Data Rate in symbols/sec
    
[match_filtered_signal] = srrc_filter(equalized_signal,span,rolloff,oversampling_factor,dataRate);

%% Demodulation (Jaino)
demodulatedBits =  Demodulation(match_filtered_signal);

%% Turbo Decoding (Joseph)
decoded_bits = TurboDecoding(demodulatedBits.');

%% TEMPORARY/TESTING
% Need to ensure decoded_bits is multiple of 7, for testing purposes, cut
% off extra bits to make multiple of 7. If we do every other step before
% this correctly, we should be getting a multiple of 7 here.
remainder = mod(length(decoded_bits), 7 );
decoded_bits = decoded_bits(1:(length(decoded_bits)-remainder), :);

%% Convert Bits to Text (Jaino)
% Bitstream_to_Text()
text = Bitstream_to_Text(decoded_bits.');
disp(text)

%% Bit Error Rate Calculations
% [number, ratio] = biterr(sendable_bits(:), decoded_bits);
% disp(number);
