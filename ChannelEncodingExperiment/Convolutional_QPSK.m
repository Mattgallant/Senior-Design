% Example SNR

clc, clear all, close all;

SNR_vector = 0:2:20;
CodedBER = zeros(length(SNR_vector),1);
BER = zeros(length(SNR_vector),1);

for snri = 1:length(SNR_vector)
    SNR = SNR_vector(snri); % SNR in decibels
    % Step 1: Create the transmitted signal
    N = 1000000;
    txbits = randi([0 1],1,2*N);
    
    % Channel Encode
    codedData = double (lteConvolutionalEncode(txbits)');
    
    % Modulation (QPSK)
    x = sqrt(1/2)*(((2*txbits(1:2:end)-1)) + 1i*(2*txbits(2:2:end)-1)).';
    coded_x = sqrt(1/2)*(((2*codedData(1:2:end)-1)) + 1i*(2*codedData(2:2:end)-1)).';
   
    % Step 2: Define energy of transmitted signal
    Energy_x = mean(abs(x).^2);
    Energy_coded_x = mean(abs(coded_x).^2);
    
    % Step 3: Define noise variance using SNR
 
    % Step 4: Create noise signal and add it to received signal
    snr = 10^(SNR/10); %Non-dB snr
    
    noise_var = Energy_x/snr;   % snr = Energy_x/noise_var
    coded_noise_var = Energy_coded_x/snr;
    % noise = sqrt(noise_var/2)*randn(N,1);
    % noise = noise - 1i*0.9*noise;
    noise = sqrt(noise_var/2)*(randn(N,1) + 1i*randn(N,1));
    coded_noise = sqrt(coded_noise_var/2)*(randn(3*N,1) + 1i*randn(3*N,1));
    
    noise_var_check = mean(abs(noise).^2);
    
    % Signal with noise added
    y = x + noise;
    coded_y = coded_x + coded_noise;
    
    SNR_check = 10*log10(Energy_x/noise_var_check);
    
    scatterplot(y)
    close all;
    scatterplot(coded_y);
    close all;
    
    
    % Bit Error Rate
    % Step 5: Convert received signal to bits
    x_quant = 1/sqrt(2)*(sign(real(y)) + 1i*sign(imag(y)));
    coded_x_quant = 1/sqrt(2)*(sign(real(coded_y)) + 1i*sign(imag(coded_y)));
    
    %error_symbols = mean(abs(x_quant - x).^2)
    
    %Get bits from symbols
    x_quant_uunormalized = sqrt(2)*x_quant;
    txbits_I = 1/2*(real(x_quant_uunormalized)+1);
    txbits_Q = 1/2*(imag(x_quant_uunormalized)+1);
    rec_bits(1:2:2*N) = txbits_I;
    rec_bits(2:2:2*N) = txbits_Q;
    
    %Get coded bits from symbols
    coded_x_quant_uunormalized = sqrt(2)*coded_x_quant;
    coded_txbits_I = 1/2*(real(coded_x_quant_uunormalized)+1);
    coded_txbits_Q = 1/2*(imag(coded_x_quant_uunormalized)+1);
    coded_rec_bits(1:2:6*N) = coded_txbits_I;
    coded_rec_bits(2:2:6*N) = coded_txbits_Q;
    
    decoded_rec_bits = double (lteConvolutionalDecode(coded_rec_bits)');
    
    [coded_err, coded_ber] = biterr(decoded_rec_bits, txbits);
    CodedBER(snri) = coded_ber;
    
    [err,ber] = biterr(rec_bits,txbits);
    BER(snri) = ber;
end

figure(1)
semilogy(SNR_vector.',BER)
xlabel('SNR (dB)')
ylabel('BER')

figure(2)
semilogy(SNR_vector.', CodedBER)
xlabel('SNR (dB)')
ylabel('BER')



