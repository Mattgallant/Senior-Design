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
read_length = 60000;

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
SNR_input_type = SNR_vector;

%% USER DEFINED ATTENTUATION PARAMETERS
gainFactor1 = 10;
gainFactor2 = 20;




%% SIMULATION %
%For now, I have just placed comments with the order of functions and what
%the expected input and output of each function should be. We will plug in
%the actual functions later

%% Bitstream Generation and Modulation (Jaino)
% Generates a bitstream from a file and modulates it using 3 different
% modulation schemes.
% Input: (numberOfBits) --> use read_length parameter
% - numberOfBits (must be a multiple of both 2 and 3)
% Output: [sourceCharacters,BPSKSignal,FourPamSignal,EightPamSignal]
% - sourceCharacters: vector of originally generated bits
% - BPSKSignal: vector of BPSK modulated bits
% - FourPamSignal: vector of 4PAM modulated bits
% - EightPamSignal: vector of 8PAM modulated bits
[sourceCharacters,BPSKSignal,FourPamSignal,EightPamSignal] = input_modulation(read_length);

%% Upsampling (Neel)
% Upsamples the input signal
% Input: (bitstream,upsample_factor,user)
% - bitstream: input signal to be upsampled
% - upsample_factor: Upsampling Factor L, a good option is 3.
% - user: true or false, if true, uses our user defined upsampler
% Output: user_upsampled_bitstream
% - user_upsampled_bitsream: new vector of upsampled signal
L = 3;
upsampledBPSKSignal = upsampler(BPSKSignal, L, true);
upsampled4PAMSignal = upsampler(FourPamSignal, L, true);
upsampled8PAMSignal = upsampler(EightPamSignal, L, true);


%% Pulse Shaping and Upconversion to Carrier Frequency(Neel)
% Useses SRRC pulse shaping and upconverts the signal to the carrier
% frequency as a cosine wave.
% Input: (x,Nsym,beta,sampsPerSym,R,Fc)
% - x: Input signal to be pulse shaped and translated to carrier freq.
% - Nsym: Filter span in symbol durations
% - beta: Rolloff factor
% - sampsPerSym: Upsampling factor (same as L above)?
% - R: Data Rate (?)
% - Fc: Desired carrier frequency
% Output:
% - yc: The resulting signal vector
carrierBPSKSignal = SRRC(upsampledBPSKSignal,Nsym,beta,sampsPerSym,R,9000);
carrier4PAMSignal = SRRC(upsampled4PAMSignal,Nsym,beta,sampsPerSym,R,9000);
carrier8PAMSignal = SRRC(upsampled8PAMSignal,Nsym,beta,sampsPerSym,R,9000);


%% SIGNAL NOW TRANSMITTED, Channel Attentuation
% Simply multiplies the gain factor across the entire signal to create the
% received signals. This will need to be done for multiple different
% modulations eventually.
receivedSignalBPSK1 = carrierBPSKSignal.*gainFactor1;
receivedSignal4PAM1 = carrier4PAMSignal.*gainFactor1;
receivedSignal8PAM1 = carrier8PAMSignal.*gainFactor1;

receivedSignalBPSK2 = carrierBPSKSignal.*gainFactor2;
receivedSignal4PAM2 = carrier4PAMSignal.*gainFactor2;
receivedSignal8PAM2 = carrier8PAMSignal.*gainFactor2;

%% Automatic Gain Control (Phat and Joseph)
% Estimates the value of the gain factor that occurred in the channel and
% corrects the input signal to correct amplitude level.

% Gradient Descent Algorithim
% Input: (r)
% - r: The signal to be equalized
% Output: [output, amplitudeOverIterations]
% - output: The amplitude equalized signal
% - amplitudeOverIterations: A vector of the amplitude estimations (TODO)
gradSignalBPSK1 = AGCgrad(receivedSignalBPSK1);
gradSignal4PAM1 = AGCgrad(receivedSignal4PAM1);
gradSignal8PAM1 = AGCgrad(receivedSignal8PAM1);

gradSignalBPSK2 = AGCgrad(receivedSignalBPSK2);
gradSignal4PAM2 = AGCgrad(receivedSignal4PAM2);
gradSignal8PAM2 = AGCgrad(receivedSignal8PAM2);

% LMS Algorithim
% Input: (r)
% - r: The signal to be equalized
% Output: [output, amplitudeOverIterations]  TODO
% - output: The amplitude equalized signal
% - amplitudeOverIterations: A vector of the amplitude estimations (TODO)
LMSSignalBPSK1 = AGC_LMS(receivedSignalBPSK1);
LMSSignal4PAM1 = AGC_LMS(receivedSignal4PAM1);
LMSSignal8PAM1 = AGC_LMS(receivedSignal8PAM1);

LMSSignalBPSK2 = AGC_LMS(receivedSignalBPSK2);
LMSSignal4PAM2 = AGC_LMS(receivedSignal4PAM2);
LMSSignal8PAM2 = AGC_LMS(receivedSignal8PAM2);

%% Training Sequence Detection (Austin and Carolyn)
% TODO


