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
%so far timingErr has not been tested much > 2733, working under assumption of similar good/bad numbers
timingErr = 2733; % Samples of timing error --- jk inconsistent BER with different numbers but 2700 is safe for benchmarking
%bad BER inconsistencies have zero_array size > 1
%example bad timingErr is 131, 2733 is pseudo bad number
%NOTE: higher SNR /does/ improve BER for some numbers (like 2733), but numbers like 131 stay bad

fixedDelay = dsp.Delay(timingErr);  %code to simulate delay from https://www.mathworks.com/help/comm/ref/comm.symbolsynchronizer-system-object.html
fixedDelaySym = ceil(fixedDelay.Length/sps); % Round fixed delay to nearest integer in symbols
%garbage = fixedDelay(txSig.').'; %this jut adds 0s but cuts off the end???
%--- no significant difference for BER between top garbage and bottom garbage lines

garbage = [zeros(1, timingErr) txSig]; %example delay but no cutting off the end
%garbage = [zeros(1, ceil(timingErr/sps)) txSig];    %this works more often - 131 still causes BER but something like 2733 works with this but not previous one
%--- one more thing of note for ^ ceil(2733/6) = 456, but timingErr = 76 (456/6) causes error for all - another bad number to ref
%garbage = [randi([0 1],timingErr, 1).' txSig]; %this is the only one that causes size errors for some values that don't when zeroes is used
%garbage = [randi([0 1],ceil(timingErr/sps), 1).' txSig];  %similar results to ceil with zeroes

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
disp("Length of timing offset signal: " + length(rxSync));

% Training sequence detection (Carolyn)
[retrieved_sequence, retrieved_data] = GolayDetection(real(rxSync), 128, training_sequence);
disp("Length of retrieved_data: " + length(retrieved_data)); %skipping timing offset for bad numbers cause size issues

%  Constellation DeMapping
demodulated_bits =  Demodulation(retrieved_data);
demodulated_bits = demodulated_bits(:);

zero_array = zeros(1, length(modulated_bits)-length(demodulated_bits));
disp("Length of zero_array: " + length(zero_array));
demodulated_bits = [demodulated_bits.' zero_array];

%  Channel Decoding
decoded_bits = TurboDecoding(demodulated_bits.');

%  Bitstream-To-TXT
%text = Bitstream_to_Text(decoded_bits);

%% Analysis

%  BER
[number, ratio] = biterr(sendable_bits(:), decoded_bits);
disp("BER: " + ratio + " Number: " + number);
