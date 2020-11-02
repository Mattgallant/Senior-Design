
%% Input Data (Text File, String)
    file_pointer= fopen("lorem.txt");   %Open file to read from
    read_length_characters = 2000;

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
    sps = 11;
    M = 2;
    k = log2(M);

    rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
    pulseShaped = upfirdn(real(bitstream_with_injection), rrcFilter, sps);
    
%% Upconversion (Matt)
% upconvert
    txSig = upconvert(real(pulseShaped));
    
%% Channel
chtaps = [1 0.5 0.1 sqrt(0.05/2)*(randn(1,20))]; % + 1i*randn(1,20))];
txSig = conv(chtaps, txSig);

garbage = [zeros(1, 233435) txSig];        % Add some garbage at the end to simulate channel

% Ps = mean(abs(txSig).^2);
% var_n = Ps/snr;
% noisySig = rx_signal = tx_signal + sqrt(var_n/2)*(randn(size(tx_signal)) + 1i*randn(size(tx_signal)))

EbNo = 25;
snr = EbNo + 10*log10(k) - 10*log10(sps);
disp("SNR: " + snr)
noisySig = awgn(garbage, snr, 'measured');

%scatterplot(noisySig(1:end));
%title('Constellation w/o CFO')

gainFactor = 1;
noisyGainSig = noisySig*gainFactor;

% Add CFO
cfoRatio = .0001;
rxSig = noisyGainSig.*exp(-j*2*pi*cfoRatio*(0:length(noisyGainSig)-1));    
%rxSig = noisyGainSig;
scatterplot(rxSig)
title('Received Signal');    
    
%% Hotfix start section
finalSig = 0;  %final signal
BER = 1;

TX_ENCODE_LENGTH = 70018;     %length of read characters from transmitter (for hardcoding size) (formula seems to be length * 35 + 18)
% figure; plotspec(rxSig, 1/44100); title("received signal ");

for i = 0 : 4       %basing off of demodulation carrier period
    rxSig = rxSig(1+i:end);
%% Downconversion
    downconverted = downconvert(rxSig);
%     figure; plotspec(downconverted, 1/44100); title(["signal run of ", num2str(i)]);
%% Matched Filter (Neel)
% MatchedFilter - takes in: equalized_signal as the result of the previous
% module
    %Filter properties - Make sure these match transmitter values 
    rolloff = 0.25;
    span = 10;
    sps = 11;
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
   [~, ratio] = biterr(sendable_bits(:), decoded_bits(1:length(sendable_bits(:))));
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