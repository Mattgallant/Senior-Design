%script for testing timing offset
%modules used - txt-to-bitstream, channel encoding, constellation mapping,
%training sequence injection, srrc, upconversion, downconversion, matched
%filter, ~timing offset~, sequence detection, demapping, decoding

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

% Training Sequence Injection (Carolyn)
% [bitstream_with_injection, training_sequence] =  golay_injection(modulated_bits, 128);
pnSequence = comm.PNSequence('Polynomial',[7 2 0],'SamplesPerFrame',128,'InitialConditions',[0 0 0 0 0 0 1]);

% Generate the PN training sequence
training_sequence = pnSequence();
training_sequence = training_sequence';
for bit = 1: length(training_sequence)
   if training_sequence(bit)== 0
        training_sequence(bit) = -1;
    end
end
% Embed training sequence into bitstream
embeddedStream = horzcat(training_sequence, modulated_bits);

%embeddedStream = [randi([0 1],6001, 1).' embeddedStream];

%  SRRC Filtering
rolloff = 0.25;
span = 10;
sps = 6;
M = 2;
k = log2(M);

rrcFilter = rcosdesign(rolloff, span, sps,'sqrt');
pulseShaped = upfirdn((embeddedStream), rrcFilter, sps);

%Upconversion
txSig = upconvert(pulseShaped);

%% Channel
timingErr = 2700; % Samples of timing error --- around 2700 for 15 EbNo before BER accumulates
fixedDelay = dsp.Delay(timingErr);
fixedDelaySym = ceil(fixedDelay.Length/sps); % Round fixed delay to nearest integer in symbols
%garbage = fixedDelay(txSig.').'; this jut adds 0s but cuts off the end???
garbage = [zeros(1, timingErr) txSig];

%garbage = [txSig]; %received is conglomerated at 0 when not a multiple of 6, but at -1,+1 ends when it is???
EbNo = 15;
snr = EbNo + 10*log10(k) - 10*log10(sps);
disp("SNR: " + snr)
rxSig = awgn(garbage, snr, 'measured');
%rxSig = garbage;

%Downconversion
downconverted = downconvert(rxSig);

%  Match (SRRC) Filtering
rxFilt = filter(rrcFilter,1, downconverted);
delay = ceil(length((rrcFilter - 1) / 2));
match_filtered_signal = [rxFilt(delay:end)];

scatterplot(match_filtered_signal);
title('received matched rx');

%timing offset
rxSync = TimingOffset(match_filtered_signal.', sps).';
scatterplot(rxSync);
title('offset corrected rx');

% Training sequence detection (Carolyn)
[retrieved_sequence, retrieved_data] = GolayDetection(real(rxSync), 128, training_sequence);

%  Constellation DeMapping
demodulated_bits =  Demodulation(retrieved_data);
demodulated_bits = demodulated_bits(:);

zero_array = zeros(1, length(modulated_bits)-length(demodulated_bits));
demodulated_bits = [demodulated_bits.' zero_array];

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits.');

%  Bitstream-To-TXT
%text = Bitstream_to_Text(decoded_bits);

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);
