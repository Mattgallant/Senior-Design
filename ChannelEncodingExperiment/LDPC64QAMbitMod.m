%!!!!!!!!!!!!! WIP !!!!!!!!!!!!!!!!!!!!!!!!
%code from https://www.mathworks.com/help/comm/ug/estimate-ldpc-performance-in-awgn.html
%pammod from https://www.mathworks.com/help/comm/ref/pammod.html

clc, clear all, close all;

ldpcEnc = comm.LDPCEncoder;
ldpcDec = comm.LDPCDecoder;

%setting modulation order and number of data points
M = 16;
num = 1000;

%modulate with gray encoding
%data = pammod(dataIn,M,0,'gray');
%dataOut = pamdemod(modData,M,0,'gray');

%scatter((1:num),modData);

snrVec = 0:2:40;
ber = zeros(length(snrVec),1);
BER = zeros(length(snrVec),1);
L = sqrt(1/8);

for k = 1:length(snrVec)
    SNR = snrVec(k);     %in db
    % Generate binary data
    N = 32400/2;        %something with LDPC funtion's parameter 
    txbits = randi([0 1],1,2*N);    
    
    % Apply LDPC encoding
    encData = ldpcEnc(logical(txbits.'));                
   
    % Modulate
    dataConvert = double(encData).';
    for i = 3:3:4*N
            transData(i/3) = bi2de([dataConvert(i-2),dataConvert(i-1), dataConvert(i)]); %should be gray encoded
    end
    modSig = L*(((2*transData(1:2:end)-7)) + 1i*(2*transData(2:2:end)-7)).';    %8 by 8 what sqrt to use?
%scatterplot(modSig)
    % Define energy of transmitted signal
    Energy_modSig = mean(abs(modSig).^2);   %this isn't 1 with ^^ sqrt
    
    % Create noise signal and add it to received signal
    snr = 10^(SNR/10);
    noise_var = Energy_modSig/snr;   % snr = Energy_x/noise_var
        
    % Pass through AWGN channel
    noise = sqrt(noise_var/2)*(randn(N/3*2,1) + 1i*randn(N/3*2,1)); %!!!!!!!!!!!watch for size
    noise_var_check = mean(abs(noise).^2);

    rxSig = modSig + noise;   %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
    SNR_check = 10*log10(Energy_modSig/noise_var_check);
%scatterplot(rxSig)

    % Bit Error Rate
    
    % Step 5: Convert received signal to bits
    
    %x_quant = 1/sqrt(8)*(sign(real(rxSig)) + 1i*sign(imag(rxSig)));
        %hold = ((sqrt(8)*(real(rxSig)))+7)/2;
        convertReal = quantalph(real(rxSig), L*[-7, -5, -3, -1, 1, 3, 5, 7]);
        convertImag = quantalph(imag(rxSig), L*[-7, -5, -3, -1, 1, 3, 5, 7]);

        x_quant = (convertReal + 1i*convertImag);
%scatterplot(x_quant)         
    error_symbols = mean(abs(x_quant - modSig).^2);
    
    % Demodulate
    x_quant_uunormalized = x_quant/L;
%scatterplot(x_quant_uunormalized)
%     txbits_I = 1/2*(real(x_quant_uunormalized)+1);
%     txbits_Q = 1/2*(imag(x_quant_uunormalized)+1);
    txbits_I = de2bi(int8((real(x_quant_uunormalized)+7)/2) ,3);
    txbits_Q = de2bi(int8((imag(x_quant_uunormalized)+7)/2) ,3);
    
    hold = [txbits_I txbits_Q];
    transHold = double(hold');
    rec_bits = transHold(:);
    
    % Decode LDPC
    demodSig = rec_bits;
error_demod = mean(abs(demodSig' - dataConvert).^2);

    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    rxData = ldpcDec(demodSig);  %something goes wrong here, error check (without noise) is ok up until this is executed

    % Compute Error
    rxDataHold = rxData.';
    rxData = xor(rxDataHold,1); %for some reason a majority of bits are flipped???
error_symbols = mean(abs(rxData - txbits).^2);

    [err,ber] = biterr(rxData,txbits);
    BER(k) = ber;
end

figure, semilogy(snrVec.',BER)
xlabel('SNR (dB)')
ylabel('BER')

