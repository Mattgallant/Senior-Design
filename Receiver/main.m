% main script for the receiver. All receiver functions should be
% plugged into this file.
% Subteam: Joseph, Austin, Phat & Carolyn
    
%% Input from microphone (Matt)
% Mic_to_Receiver(Seconds to record)
    rxSig = Mic_to_Receiver(3); % Record for 5 seconds
%     audiowrite("test.mp4", rxSig, 44100);
%     disp("Recorded : " + length(rxSig) + " bits")
%     [file, fs] = audioread('test.wav');
%     noise = [zeros(1,15700) file.' zeros(1,29567)];
%     rxSig = awgn(noise, 50, 'measured');
%     figure;
%     plottf(rxSig, 1/Fs);
%     title('Received Sound')

    % Read in a prerecorded transmission instead
%     [rxSig,Fs] = audioread('rxSig.mp4');
%     rxSig = rxSig.';
%% Hotfix start section
finalSig = 0;  %final signal
BER = 1;

TX_ENCODE_LENGTH = 7017;     %length of read characters from transmitter (for hardcoding size) (formula seems to be length * 35 + 18)
% figure; plotspec(rxSig, 1/44100); title("received signal ");

for i = 0 : 4       %basing off of demodulation carrier period
    rxSig = rxSig(1+i:end);
%% Downconversion
    downconverted = downconvert(rxSig);
    figure; plotspec(downconverted, 1/44100); title(["signal run of ", num2str(i)]);
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

    rxFilt = conv(rrcFilter, downconverted);
    delay = ceil(length((rrcFilter - 1) / 2));
    match_filtered_signal = [rxFilt(delay:end)];
    
%%  Carrier Frequency Offset Recovery
    rxCFO = CarrierFrequencyOffset(match_filtered_signal);

%% Timing Offset Recovery
    rxSync = TimingOffset(rxCFO(:), sps).';

    
%% Training sequence detection (Carolyn)
% GolayDetection()
    sequence_length = 128; % Length established in main transmitter script
    [Ga,~] = wlanGolaySequence(sequence_length);
    training_sequence = reshape(Ga, [1,sequence_length]);
    
    [retrieved_sequence, retrieved_data] = GolayDetection(rxSync, 128, training_sequence);
    
%% Hotfix section 
   if(length(retrieved_data) >= TX_ENCODE_LENGTH)
       retrieved_data = retrieved_data(1:TX_ENCODE_LENGTH);
    
%% Automatic Gain Control (Phat) - current method relies on training sequence
% AGC_KnownFunction(signal to be equalized, known signal)
    estimatedGain = AGC_KnownFunction(retrieved_sequence, training_sequence);
    gainCorrectedSignal = retrieved_data./estimatedGain;
    gainCorrectedSequence = retrieved_sequence./estimatedGain;
%     rx_equalized= gainCorrectedSequence;

%% Channel Estimation and Equalization
   [rx_equalized, err] = ChannelEstimation(gainCorrectedSequence, gainCorrectedSignal, training_sequence);

%% Demodulation (Jaino)
    demodulatedBits =  Demodulation(rx_equalized);

%% Turbo Decoding (Joseph)
    decoded_bits = TurboDecoding(demodulatedBits);

%% Hotfix end section
   [~, ratio] = biterr(sendable_bits(:), decoded_bits);
   if (ratio < BER)
       BER = ratio;
       finalSig = decoded_bits;
   end
   end          % if statement for length end

end    
decoded_bits = finalSig;
if(BER == 1)
    disp("resend signal");
end

%% Convert Bits to Text (Jaino)
% Bitstream_to_Text()
    % Cutoff last bits to make multiple of 7.
    remainder = mod(length(decoded_bits), 7 );
    decoded_bits = decoded_bits(1:(length(decoded_bits)-remainder), :);

    text = Bitstream_to_Text(decoded_bits.');
    disp(text)
    
%% Bit Error Rate Calculations
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);
