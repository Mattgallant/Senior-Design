% 16-QAM in Gray Code Adapted from Javi's Example SNR code?
%UNFINISHED
SNR_vector = 0:2:20;
BER = zeros(length(SNR_vector),1);

for snri = 1:length(SNR_vector)
    % SNR in decibels
    SNR = SNR_vector(snri); 
    
    % Step 1: Create the transmitted signal  
    %N: number of bits per message
    N = 16*10^4;  
    %txtbits: input bitstream
    txtbits = randi([0 1],1,2*N);
    %alphabet: 16-QAM magnitude mappings
    alphabet = [-3 -1 1 3];
    %creating mappings, uses the fact that:
    % 0,0 = xor(0,floor(0),xor(0,floor(0) = 0,0
    % 0,1 = xor(0,floor(0),xor(1,floor(0) = 0,1
    % 1,0 = xor(1,floor(0),xor(0,floor(1) = 1,1
    % 1,1 = xor(1,floor(0),xor(1,floor(1) = 1,0
    %seperates txtbits into pairs of 2
    bitpairs = reshape(txtbits',2,[])';
    %bitpairs = padarray(bitpairs,[0 2],0,'pre');
    %real pairs are bit 1,0 of 4 bit sequence e.g. odd rows
    
    %NEED TO FIGURE OUT CHAR VECTOR OR MAKE CUSTOM BIN2DEC FUNCTION
    
    real_pairs = bi2de(bitpairs(1:2:end,:));
    real_pairs_gray = bitxor(real_pairs,floor(real_pairs/2));
    %imaginary pairs are bit 3,2 of 4 bit sequence e.g. even rows
    imag_pairs = bi2de(bitpairs(2:2:end,:));
    imag_pairs_gray = bitxor(imag_pairs,floor(imag_pairs/2));
    %mapping gray symbols
    mod_real = alphabet(real_pairs_gray + 1);
    mod_imag = alphabet(imag_pairs_gray + 1);
    %adding real and imaginary parts to create the mapped message
    message = mod_real + 1i*mod_imag;
    %make a scatterplot of message
    scatterplot(message)
    close all;
    
    % Step 2: Define energy of transmitted signal
    Energy_x = mean(abs(message).^2);
    
    % Step 3: Define noise variance using SNR
    
    
    % Step 4: Create noise signal and add it to received signal
    
    snr = 10^(SNR/10);
    
    noise_var = Energy_x/snr;   % snr = Energy_x/noise_var
    % noise = sqrt(noise_var/2)*randn(N,1);
    % noise = noise - 1i*0.9*noise;
    noise = sqrt(noise_var/2)*(randn(N/2,1) + 1i*randn(N/2,1));
    noise_var_check = mean(abs(noise).^2);
    
    m = message(:);
    
    y = m + noise;
    
    SNR_check = 10*log10(Energy_x/noise_var_check);
    
    scatterplot(y)
    close all;
    
    %TODO Demodulate
    
    
    % Bit Error Rate
    
    % Step 5: Convert received signal to bits
    
    x_quant = 1/sqrt(2)*(sign(real(y)) + 1i*sign(imag(y)));
    
    error_symbols = mean(abs(x_quant - m).^2);
    
    x_quant_uunormalized = sqrt(2)*x_quant;
    txbits_I = 1/2*(real(x_quant_uunormalized)+1);
    txbits_Q = 1/2*(imag(x_quant_uunormalized)+1);
    rec_bits(1:2:2*N) = txbits_I;
    rec_bits(2:2:2*N) = txbits_Q;
    
    [err,ber] = biterr(rec_bits,txbits);
    BER(snri) = ber;
end
figure, semilogy(SNR_vector.',BER)
xlabel('SNR (dB)')
ylabel('BER')
