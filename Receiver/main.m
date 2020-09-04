% main script for the receiver. All receiver functions should be
% plugged into this file.

%% Input from microphone (Matt)
% Mic_to_Receiver(Seconds to record)
    binary_input = Mic_to_Receiver(5); % Record for 5 seconds
    disp(binary_input)

%% Training sequence detection (Carolyn)
% GolayDetection()

%% Timing Offset (Phat) - TBD after detection implementation
% TimingOffset() 

%% Carrier Frequency Offset (Austin)
% CarrierFrequencyOffset()

%% Automatic Gain Control (Phat) - current method relies on training sequence
% AGC_KnownFunction(signal to be equalized, known signal)
    %estimatedGain = AGC_KnownFunction(receivedSignal, trainingSequence);
    %gainCorrectedSignal = receivedSignal/estimatedGain;

%% Channel Estimation (Jaino)
% ChannelEstimation()

%% Channel Equalization (Joseph)
% ChannelEqualization()

%% Matched Filter (Neel)
% MatchedFilter

%% Demodulation (Jaino)
% Demodulation()
    %demodulatedBits =  Demodulation(BPSKSignal);

%% Turbo Decoding (Joseph)
% TurboDecoding()

%% Convert Bits to Text (Jaino)
% Bitstream_to_Text()

%% Bit Error Rate Calculations
% BER_Calculations - function or part of script?