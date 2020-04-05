%Implementation of LDPC code using 16-QAM - Adapted from MATLAB Example:
%LDPC - QPSK code
%Modulation order (16-QAM)
M = 16;
%Bits per symbol
k = log2(M);
%Number of bits 
n = 32400;
%Number of samples per symbol
L = 1;
%SNR valuees to test
snr = [0.25,0.5,0.75,1.0,1.25];
%Error rate variables
error_rate = zeros(1,length(snr));
unc_error_rate = zeros(1,length(snr));
%Generate random data (binary)
rng default;
message = randi([0 1], n, 1);
%Init. LDPC encoder and decoder
ldpcEncoder = comm.LDPCEncoder;
ldpcDecoder = comm.LDPCDecoder;
%Encode data
e_message = ldpcEncoder(message);
%Convert encoded binary message into integer for qammod in gray coding
%TODO Write 16QAM encoder from scratch
e_message_matrix = reshape(e_message,length(e_message)/k,k);
e_message_mod_input = bi2de(e_message_matrix);
e_message_mod_gray = qammod(e_message_mod_input,M);
%Convert un-encoded binary message into integer for qammod in gray coding
unc_message_matrix = reshape(message,length(message)/k,k);
unc_message_mod_input = bi2de(unc_message_matrix);
unc_message_mod_gray = qammod(unc_message_mod_input,M);
%Loop through the different SNR values
for ii = 1 : length(snr)
    %Pass signal through AWGN Channel
    %TODO Write AWGN Channel from scratch
    r_signal_gray = awgn(e_message_mod_gray,snr(ii),'measured');
    unc_r_singal_gray = awgn(unc_message_mod_gray,snr(ii),'measured');
    %Demodulate recived signal
    e_message_demod_dec = qamdemod(r_signal_gray,M);
    unc_message_demod_dec = qamdemod(unc_r_singal_gray,M);
    %Convert integer-valued demodulation to binary demodulation
    e_message_demod_matrix = de2bi(e_message_demod_dec,k);
    e_message_demod = e_message_demod_matrix(:);
    unc_message_demod_matrix = de2bi(unc_message_demod_dec,k);
    unc_message_demod = unc_message_demod_matrix(:);
    %Decode demodulated signal into bits
    message_decode = ldpcDecoder(e_message_demod);
    %Calcualte local and total bit error 
    num_err = biterr(message,message_decode);
    %total_err = total_err + num_err;
    unc_num_err = biterr(message,unc_message_demod);
    %unc_total_err = unc_total_err + unc_num_err;
    error_rate(ii) = num_err / n;
    unc_error_rate(ii) = unc_num_err  / n;
end
%Plot BER vs. SNR
plot(snr,unc_error_rate,snr,error_rate);
legend('Uncoded','LDPC Coded');
xlabel('SNR (db)');
ylabel('BER');

