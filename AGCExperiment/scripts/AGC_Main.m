%Description: Tests the functionality of AGC. This is the main file for
%this experiment. All functions should be plugged into this file so it can
%be tested.

%% USER DEFINED GENERAL PARAMETERS

%Random Number Generator settings
rng_setting = 'default';

%% USER DEFINED BITSTREAM PARAMETERS

%Data Source: 'file' || 'random' ||  'fixed'
%   'file': reads input from a file
%   'random': generates random 0 and 1 data
%   'fixed': uses a manually defined bitstream array
data_source_selector = 'file';

%IF data_source_selector = 'file', these values are used
%   file_name: name of the file to read from
%   read_length: number of chars to read from the file
file_name = ''; %Our current function just uses alice_in_wonderland.txt
read_length = 59968;

%IF data_source_selector = 'random'
%   rand_length: how many random bits to generate
rand_length = 0;

%IF data_source_selector = 'fixed'
%   fixed_ bitstream: the fixed bitstream as a row vector
fixed_bitstream = [ 0 1 0 0 1 1 0 0 0 1 1 1 0];

%General Bitstream Parameters
%   bitstream_format: the format of the bitstream: 'double' || 'logical;
%   column: if true, make the bitstream a column vector
bitstream_format = 'double';
column = false;

%% USER DEFINED ENCODING PARAMETERS (unused)
%We do not intend to use encoding for this experiment, but this is nice to
%have incase we come back and add it to this experiment.

%Encoding Type: 'LDPC' || 'Turbo' || 'Convolutional'
%   'LDPC': uses comm.LDPCEncoder and comm.LDPCDecoder on default settings
%   'Turbo': LTE Turbocode
%   'Convolutional': 
encoding_type = 'Convolutional';

%General coding properties 
%   bitrate: sets the bitrate for the encoding, default: 1
bitrate = 1;

%% USER DEFINED MODULATION PARAMETERS
%For this experiment, we will currently be just testing BPSK, 4PAM & 8PAM

%Modulation Type: 'BPSK' || '4PAM' || '8PAM' || 'QAM'
%   QAM: Quadrature Amplitude Modulation (16 || 64)
%   QPSK: Quadrature Phase Shift Keying
%   BPSK: Binary Phase Shift Keying
%   4PAM: Pulse Amplitude Modulation, modulation order 4
modulation_type = 'BPSK';

%IF modulation_type = 'QAM'
%   M: modulation order, default 16
%   demodulation_decision: 'soft' || 'hard'
%       'soft': uses approx. llr with noise variance set
%       'hard': uses exact llr with noie variance set
M = 16;
demodulation_decision = 'soft';

%% Signal to Noise Ratio Test Values
%IF SNR_input_type = 'SNR_vector'
%   SNR_vector: define SNR values with range and step size
SNR_vector = 0:2:40;

%IF SNR_input_type = 'EbNo'
%   EbNo: define EbNo range with step size of 1
EbNo = (0:12)';

%SNR Input Type: 'SNR_vector' || 'EbNo'
%   'SNR_vector': uses a defined set of SNR values in db
%   'EbNo': uses a defines set of EbNo values in db
SNR_input = SNR_vector;

%% USER DEFINED ATTENTUATION PARAMETERS
gainFactor = 10;

%% USER DEFINED AGC PARAMETERS
%AGC Algo: 'grad' || 'lms'
AGC_algo = 'grad';

%% USER DEFINED TRAINING SEQUENCE PARAMETERS
%Training Algo: 'golay' || 'pn'
training_algo = 'golay';
loc = 50;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SIMULATION %
%For now, I have just placed comments with the order of functions and what
%the expected input and output of each function should be. We will plug in
%the actual functions later

%% Bitstream Generation (Jaino)
% Generates a bitstream from a file.
% Input: (numberOfBits) --> use read_length parameter
% - numberOfBits (must be a multiple of both 2 and 3)
% Output: [sourceCharacters, sendableBits]
% - soruceCharacters: 2D Matrix of ASCII values
% - sendableBits: The resulting bitstream
[sourceCharacters, sendableBits] = Input(read_length);

%% Training Sequence Injection (Austin, Carolyn)
% Embeds the training sequence to the bit stream
% Input: (sendableBits, loc)
    % - sendableBits: Input stream signal
    % - loc: location index of where training sequence is embedded
% Output: (sourceWithTrainingSignal, training_sequence)
    % - sourceWithTrainingSignal: bitsream with embedded sequence
    % - training_sequence: Corresponding training sequence (golay or pn)
switch training_algo
    case 'golay'
        % Input: (sendableBits,loc)
        % - sendableBits: Input stream signal
        % - loc: location index of where training sequence is embedded
        % Output: (sourceWithTrainingSignal, training_sequence)
        % - sourceWithTrainingSignal: bitsream with embedded sequence
        % - training_sequence: Pseudonoise training_sequence
       [sourceWithTrainingSignal, training_sequence] =  golay_sequence_generation(sendableBits, loc);
       disp(training_sequence);
    case 'pn'
        % Input: (sendableBits,loc)
        % - sendableBits: Input stream signal
        % - loc: location index of where training sequence is embedded
        % Output: (sourceWithTrainingSignal, training_sequence)
        % - sourceWithTrainingSignal: bitsream with embedded sequence
        % - training_sequence: Pseudonoise training_sequence
       [sourceWithTrainingSignal, training_sequence] =  Embed_PNSequence(sendableBits,loc);
    otherwise
       [sourceWithTrainingSignal, training_sequence] =  golay_sequence_generation(sendableBits, loc);
end

%% Signal Modulation (Jaino)
% Modulates the input signal using a given modulation scheme. takes
% sourceWithTrainingSignal and modulates
% [BPSKSignal,FourPamSignal,EightPamSignal] = Modulation(sendableBits)
% Input: TODO
% - sendableBits: Vector of bits to be modulated
% Output:
% - 
[BPSKSignal,FourPamSignal, EightPamSignal] = Modulation(sourceWithTrainingSignal);
switch modulation_type
    case 'BPSK'
        modulatedSignal = BPSKSignal;
    case '4PAM'
        modulatedSignal = FourPamSignal;
    case '8PAM'
        modulatedSignal = EightPamSignal;
    otherwise 
        modulatedSignal = BPSKSignal;
end
       
   
%% Upsampling (Neel)
% Upsamples the input signal
% Input: (bitstream,upsample_factor,user)
% - bitstream: input signal to be upsampled
% - upsample_factor: Upsampling Factor L, a good option is 3.
% - user: true or false, if true, uses our user defined upsampler
% Output: user_upsampled_bitstream
% - user_upsampled_bitsream: new vector of upsampled signal
L = 3;
%upsampledSignal = upsampler(modulatedSignal', L, true);


%% Pulse Shaping and Upconversion to Carrier Frequency(Neel)
% Useses SRRC pulse shaping and upconverts the signal to the carrier
% frequency as a cosine wave.
% Input: (x,Nsym,beta,sampsPerSym,R,Fc)
% - x: Input signal to be pulse shaped and translated to carrier freq.
% - Nsym: Filter span in symbol durations (?)
% - beta: Rolloff factor (?)
% - sampsPerSym: Upsampling factor (same as L above)?
% - R: Data Rate (?)
% - Fc: Desired carrier frequency
% Output:
% - yc: The resulting signal vector
Nsym = 6;
beta = 1;
sampsPerSym = 6;
R = 500;
Fc = 9000;
[transmissionTimes, carrierSignal] = SRRC(modulatedSignal,Nsym,beta,L,R,Fc);


%% SIGNAL NOW TRANSMITTED, Channel Attentuation
% Simply multiplies the gain factor across the entire signal to create the
% received signals. This will need to be done for multiple different
% modulations eventually.
gainSignal = carrierSignal.*gainFactor;

%Add AWGN based on the SNR and Attenuation Factor!
SNR = (gainSignal^2)*SNR_input;
receivedSignal = awgn(gainSignal, SNR); %SNR must be in DB

%% Automatic Gain Control (Phat and Joseph)
% Estimates the value of the gain factor that occurred in the channel and
% corrects the input signal to correct amplitude level.
switch AGC_algo
    case 'grad'
        % Gradient Descent Algorithim
        % Input: (r)
        % - r: The signal to be equalized
        % Output: [output, amplitudeOverIterations]
        % - output: The amplitude equalized signal
        % - amplitudeOverIterations: A vector of the amplitude estimations (TODO)
        [gainControlledSignal, gainEstimation] = AGCgrad(receivedSignal);
    case 'lms'
        % LMS Algorithim
        % Input: (r)
        % - r: The signal to be equalized
        % Output: [output, estimations]  TODO
        % - output: The amplitude equalized signal
        % - estimations: A vector of the amplitude estimations (TODO)
        [gainControlledSignal, gainEstimation] = AGC_LMS(receivedSignal);
    otherwise
        [gainControlledSignal, gainEstimation] = AGCgrad(receivedSignal);
end


%% Training Sequence Detection (Austin and Carolyn)
% Detects the corresponding training sequence (golay or pn) and plots it
% Input: (gainControlledSignal, training_sequence)
    % - gainControlledSignal: amplitude equalized signal
    % - training_sequence: Generated training sequence (golay or pn)
% Output: void
switch training_algo
    case 'golay'
        % Input: (training_sequence, gainControlledSignal)
        % - gainControlledSignal: amplitude equalized signal
        % - trainging_sequence: Generated golay sequence
        % Output: void
       golay_sequence_detection(gainControlledSignal, training_sequence);
    case 'pn'
        % Input: (gainControlledSignal, training_sequence)
        % - gainControlledSignal: amplitude equalized signal
        % - training_sequence: Generated Pseudonoise sequence
        % Output: void
       PNSequence_detection(gainControlledSignal, training_sequence);
    otherwise
       golay_sequence_detection(training_sequence, gainControlledSignal);
end




%% Plots (Matt)
% TODO



% Plot the Gain Estimate vs Iteration
iterations = linspace(0, length(gainEstimation), length(gainEstimation));

figure(1)
semilogy(iterations, gainEstimation);
title('Coded vs. Non-coded QPSK')
xlabel('Iteration')
ylabel('Gain Factor Estimate')
%axis([-2 10 10e-5 1])

% Plot the BER vs SNR
figure(2)
semilogy(SNR_input.', BER)
title("BER vs SNR for " + modulation_type + " modulated signal using " + agc_algo + " AGC");
xlabel('SNR (dB)')
ylabel('BER')
%axis([-2 10 10e-5 1])




