%Description: Tests the functionality of AGC

%USER DEFINED GENERAL PARAMETERS

%Random Number Generator settings
rng_setting = 'default';

%USER DEFINED BITSTREAM PARAMETERS

%Data Source: 'file' || 'random' ||  'fixed'
%   'file': reads input from a file
%   'random': generates random 0 and 1 data
%   'fixed': uses a manually defined bitstream array
data_source_selector = 'random';

%IF data_source_selector = 'file', these values are used
%   file_name: name of the file to read from
%   read_length: number of chars to read from the file
file_name = '';
read_length = 0;

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

%USER DEFINED ENCODING PARAMETERS

%Encoding Type: 'LDPC' || 'Turbo' || 'Convolutional'
%   'LDPC': uses comm.LDPCEncoder and comm.LDPCDecoder on default settings
%   'Turbo': LTE Turbocode
%   'Convolutional': 
encoding_type = 'Convolutional';

%General coding properties 
%   bitrate: sets the bitrate for the encoding, default: 1
bitrate = 1;

%USER DEFINED MODULATION PARAMETERS

%Modulation Type: 'QAM' || 'QPSK' || 'BPSK' || '4PAM'
%   QAM: Quadrature Amplitude Modulation (16 || 64)
%   QPSK: Quadrature Phase Shift Keying
%   BPSK: Binary Phase Shift Keying
%   4PAM: Pulse Amplitude Modulation, modulation order 4
modulation_type = 'QPSK';

%IF modulation_type = 'QAM'
%   M: modulation order, default 16
%   demodulation_decision: 'soft' || 'hard'
%       'soft': uses approx. llr with noise variance set
%       'hard': uses exact llr with noie variance set
M = 16;
demodulation_decision = 'soft';

%SNR Input Type: 'SNR_vector' || 'EbNo'
%   'SNR_vector': uses a defined set of SNR values in db
%   'EbNo': uses a defines set of EbNo values in db
SNR_input_type = 'SNR_vector';

%IF SNR_input_type = 'SNR_vector'
%   SNR_vector: define SNR values with range and step size
SNR_vector = 0:2:40;

%IF SNR_input_type = 'EbNo'
%   EbNo: define EbNo range with step size of 1
EbNo = (0:12)';



