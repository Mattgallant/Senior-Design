%% LVL 7
%  Implemented - Input Data, TXT-To-Bitstream, Consetellation Mapping, 
%  Golay Injection, Channel Encoding, SRRC, Match Filtering, Timing Offset,
%  Golay Sequence Detection, Upconversion, Downconversion, AGC, Decoding, 
%  Demapping, Bitstream-To-TXT, Carrier Offset. 

%  Not yet implemented - Channel estimation/equalization

Fs = 44100;
%% Transmitter
%  Input Data
file_pointer= fopen("lorem.txt"); 
read_length_characters = 2000; 

%  TXT-To-Bitstream
[source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);

%  Channel Encoding
encoded_bits = turbo_encoding(sendable_bits.');

%  Constellation Mapping
modulated_bits = BPSK_mapping(encoded_bits);

% Golay Sequence Injection
[bitstream_with_injection, training_sequence] =  golay_injection(modulated_bits, 128);

%  SRRC Filtering
rolloff = 0.25;
span = 10;
sps = 6;
M = 2;
k = log2(M);

rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
pulseShaped = upfirdn(real(bitstream_with_injection), rrcFilter, sps);

%Upconversion
txSig = upconvert(pulseShaped);

%% Channel
garbage = [zeros(1, 233435) txSig];        % Add some garbage at the end to simulate channel 
EbNo = 15;
snr = EbNo + 10*log10(k) - 10*log10(sps);
disp("SNR: " + snr)
noisySig = awgn(garbage, snr, 'measured');

scatterplot(noisySig(1:end));
title('Constellation w/o CFO')

gainFactor = 3;
noisyGainSig = noisySig*gainFactor;

% Add CFO
cfoRatio = .0001;
rxSig = noisyGainSig.*exp(-j*2*pi*cfoRatio*(0:length(noisyGainSig)-1));    
scatterplot(rxSig)
title('Transmitted signal w/ CFO');

%figure;
%plotspec(cfo, 1/Fs)
%title('Transmitted signal w/ AWGN and CFO');

% rxSig = noisyGainSig;
% SNR_ = (gainFactor^2)*snr;
% receivedPower = mean(abs(rxSig).^2);
% receivedSignal = rxSig + sqrt(receivedPower/SNR_)*randn(1,length(rxSig));
%% Reciever

%Downconversion
downconverted = downconvert(rxSig);

%  Match (SRRC) Filtering
rxFilt = filter(rrcFilter,1, downconverted);
delay = ceil(length((rrcFilter - 1) / 2));
match_filtered_signal = [rxFilt(delay:end)];

% Carrier Frequency Sync
rxCFO = CarrierFrequencyOffset(match_filtered_signal);
scatterplot(rxCFO)
title('Received signal after CFO compensation');

% Timing offset
rxSync = TimingOffset(rxCFO, sps).';

% Golay Sequence Detection
[retrieved_sequence, retrieved_data] = GolayDetection(rxSync, 128, training_sequence);

% Automatic Gain Control
estimatedGain = AGC_KnownFunction(retrieved_sequence, training_sequence);
gainCorrectedSignal = retrieved_data./estimatedGain;
gainCorrectedSequence = retrieved_sequence./estimatedGain;

%  Constellation DeMapping
demodulated_bits =  Demodulation(gainCorrectedSignal);
demodulated_bits = demodulated_bits(:);

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits.');

%  Bitstream-To-TXT
text = Bitstream_to_Text(decoded_bits);

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);