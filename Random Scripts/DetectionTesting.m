% Script for training detection verification. Must be able to detect the
% transmitted signal after all channel impairments
%% TRANSMITTER ------------------------------------------------------------
%% Input Data (Text File, String)
    file_pointer= fopen("lorem.txt"); %Open file to read from
    read_length_characters = 2000; % DO NOT CHANGE THIS FOR NOW, INTERLEAVER INDICIES NEEDS 2000

%% Bitstream Conversion (Jaino)
% text_to_bitstream
    [source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);
    %disp(sendable_bits) %Currently a row vector
    %disp(source_characters)
    [text] = bitstream_to_text(sendable_bits);
   

%% Channel Encoding (Joseph) 
% turbo_encoding
   %interleaver_indicies = randperm(length(sendable_bits.'));
   encoded_bits = turbo_encoding(sendable_bits.');
   %disp(encoded_bits); %Currently a col vector

%% Constellation Mapping (Jaino)
% BPSK_mapping
    modulated_bits = BPSK_mapping(encoded_bits);
    %disp(modulated_bits); %Currently a row vector
    %modulated_bit_length = length(modulated_bits);
    %disp(modulated_bit_length)

%% Training Sequence Injection (Carolyn)
% golay_injection
    [bitstream_with_injection, training_sequence] =  golay_injection(modulated_bits, 128);

%% Pulse Shaping & Upsampling(Neel) -- !!!detection still needs to accommodate upsampling currently skipping upsampling!!!
% srrc_filter
% Filter properties
    oversampling_factor = 4; % Number of samples per symbol (oversampling factor)
    span = 10; % Filter length in symbols
    rolloff = .1; % Filter rolloff factor
    dataRate = 500; %Data Rate in symbols/sec
   %[pulse_shaped_signal] = srrc_filter(bitstream_with_injection,span,rolloff,oversampling_factor,dataRate);
%Design SRRC filter, (optinal) visualize impulse response

upsample = zeros(1, length(bitstream_with_injection) * oversampling_factor);
upsample(1:oversampling_factor: length(bitstream_with_injection) * oversampling_factor) = bitstream_with_injection;

srrc = rcosdesign(rolloff,span,oversampling_factor,'sqrt');
%Normalize filter
srrc = srrc * 1/max(srrc);

y = srrc_filter(bitstream_with_injection,span,rolloff,oversampling_factor,dataRate);%filter(srrc,1,upsample);
pulse_shaped_signal = y;
   
%% Upconversion (Matt) -- downconvert works but peak isn't as clear
% upconvert
    %wave = randi(10, 1, 5*44100);       % For testing purposes
    %upconverted_wave = upconvert(real(pulse_shaped_signal));
fc = 9000;    % As per project definition, center freq 9kHz
fs = 44100;                 % Sampling Frequency of 44.1kHz (Samples per Second)
Ts = 1/fs;                  %sampling time
numSamples = length(pulse_shaped_signal);
n = 1 : numSamples;
t = n * Ts;
c=cos(2*pi*fc*t);
upconverted_wave = c .* pulse_shaped_signal;

%% Output to speaker (Matt) OMMITING THIS IN SIMULATION
% transmitter_to_speaker
%     disp(length(upconverted_wave));
%     transmitter_to_speaker(upconverted_wave);
    
    
%% CHANNEL ----------------------------------------------------------------
% At this point the sent wave is in the channel
% Apply noise, distortion and frequency offset

% Defining variables and objects for channel simulation
pfo = comm.PhaseFrequencyOffset('PhaseOffset',45,'FrequencyOffset',1e6);
snr = 10;    % Signal-to-Noise Ratio
channel_coeffs=[0.5 1 -0.6 .2i];              

% Applying channel effects
frequency_offset_wave = pfo(upconverted_wave);                    % Add frequency/phase offset
distorted_wave = filter(channel_coeffs,1,frequency_offset_wave);  % Add channel distortion (multipath interference)
received_signal = awgn(distorted_wave,snr);                       % Add white noise

%just bitstream through channel
release(pfo);
frequency_offset_wave_c = pfo(bitstream_with_injection);                    % Add frequency/phase offset
distorted_wave_c = filter(channel_coeffs,1,frequency_offset_wave_c);  % Add channel distortion (multipath interference)
received_signal_c = awgn(distorted_wave_c,snr);   

%% RECEIVER ---------------------------------------------------------------
%downconvert
fc = 9000;    % As per project definition, center freq 9kHz
numSamples = length(received_signal);
n = 1 : numSamples;
t = n * Ts;
c2=cos(2*pi*fc*t);

x2 = 2 * (received_signal .* c2);     %downconvert and * 2 for scaling
%LPF??
fl=floor(50);                         % LPF length
fbe=[0 0.1 0.2 1]; damps=[1 1 0 0 ];  % design of LPF parameters
b=firpm(fl,fbe,damps);                % calculation of LPF impulse response
filtered=2*filter(b,1,x2);                  % LPF and scale downconverted signal

%matched filter
y = MatchedFilter(filtered,span,rolloff,oversampling_factor,dataRate);%filter(srrc,1,filtered);
%Correct for propagation delay;
data = y;

%data = matched(1:oversampling_factor: length(bitstream_with_injection) * oversampling_factor);
%detection
y= conv(data, fliplr(training_sequence));%xcorr(training_sequence, data);
yclean = conv(received_signal_c, fliplr(training_sequence));%xcorr(training_sequence, received_signal_c);
figure;
stem(y);                            %detection works if graph shows an obvious peak
title('Detection Stem');
figure;
stem(yclean);
title('detection without upconversion/srrc');

figure;
stem(training_sequence);
title('training sequence');
figure;
stem(data(1:200));
title('through upconversion/srrc');
figure;
stem(received_signal_c(1:200));

figure;
plotspec(pulse_shaped_signal, Ts);
title('signal before modulation');
figure;
plotspec(upconverted_wave, Ts);
title('signal after modulation');
figure;
plotspec(filtered, Ts);
title('signal after demodulation (still has noise)');
