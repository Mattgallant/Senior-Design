% Convolutional QPSK. This script simulates both an uncoded QPSK
% transmition and a coded version using convolutional code with rate 1/3.
clc, clear all, close all;

%Create vectors that will be used to plot and generate data
SNR_vector = 0:2:40;                                    %Start:StepSize:End
CodedBER = zeros(length(SNR_vector),1);
BER = zeros(length(SNR_vector),1);

N = 100000;                                             %Size of the bitstream

%Simulate non-coded QPSK
for snri = 1:length(SNR_vector)
    SNR = SNR_vector(snri);                             % SNR in decibels
    
    % Step 1: Create the transmitted signal
    txbits = randi([0 1],1,2*N);                        %Initial input stream
    
    % Modulation (QPSK)
    x = sqrt(1/2)*(((2*txbits(1:2:end)-1)) + 1i*(2*txbits(2:2:end)-1)).';
   
    % Step 2: Define energy of transmitted signal. Energy_x and
    % Engery_coded_x should be equal in theory.
    Energy_x = mean(abs(x).^2);
    
    % Step 3: Define noise variance using SNR
    snr = 10^(SNR/10);                                  %Non-dB snr
    noise_var = Energy_x/snr;                           %Recall: snr = Energy_x/noise_var
    
    % Step 4: Create noise signal and add it to received signal
    noise = sqrt(noise_var/2)*(randn(N,1) + 1i*randn(N,1));
    
    % Signal with noise added
    y = x + noise;
    
    % AT THIS POINT, THE SIGNAL HAS BEEN TRANSMITTED!
    
    % Bit Error Rate
    % Step 5: Convert received signal to bits
    % Quantize the noisy signal to QPSK symbols
    x_quant = 1/sqrt(2)*(sign(real(y)) + 1i*sign(imag(y)));
    
    %error_symbols = mean(abs(x_quant - x).^2)
    
    %Get bits from symbols
    x_quant_uunormalized = sqrt(2)*x_quant;
    txbits_I = 1/2*(real(x_quant_uunormalized)+1);
    txbits_Q = 1/2*(imag(x_quant_uunormalized)+1);
    rec_bits(1:2:2*N) = txbits_I;
    rec_bits(2:2:2*N) = txbits_Q;
    
    [err,ber] = biterr(rec_bits,txbits);
    BER(snri) = ber;
end


%Simulate convolutionally encoded QPSK

%Initializtion
qpskMod = comm.QPSKModulator('BitInput',true);
demodLLR = comm.QPSKDemodulator('BitOutput',true,'DecisionMethod','Log-likelihood ratio');

chan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)');

%Code Properties...
constLen = 7;
codeGenPoly = [171 133];
tblen = 32;
trellis = poly2trellis(constLen,codeGenPoly);
encoder = comm.ConvolutionalEncoder(trellis);           % Create convolutional encoder
decSoft = comm.ViterbiDecoder(trellis,'InputFormat','Soft', ...
    'SoftInputWordLength',3,'TracebackDepth',tblen);

scalQuant = dsp.ScalarQuantizerEncoder('Partitioning','Unbounded');

errSoft = comm.ErrorRate('ReceiveDelay',tblen);         % BER calculation object

for snri = 1:length(SNR_vector)
    SNR = SNR_vector(snri);                             % SNR in decibels
    chan.SNR = SNR;                                     % Set the noise channel SNR
    
    txbits = randi([0 1],1,2*N)';                       %Initial input stream
    encData = encoder(txbits);                          %Encode the data
    modData = qpskMod(encData);                         %Modulate the data
    
    Energy_x = mean(abs(modData).^2);
    snr = 10^(SNR/10);
    NoiseVariance = Energy_x/snr;
    demodLLR.Variance = NoiseVariance;
    scalQuant.BoundaryPoints = (-1.5:0.5:1.5)/NoiseVariance;
    
%     noise = sqrt(NoiseVariance/2)*(randn(2*N,1) + 1i*randn(2*N,1));
%     receivedSignal = noise + modData;
    receivedSignal = chan(modData);                     %Add noise to the signal
    
    LLRData = demodLLR(receivedSignal);                 %Demodulate the received signal and output LLR values
    
    quantizedValue = scalQuant(-LLRData);
    rxDataSoft = decSoft(double(quantizedValue));
    berSoft = errSoft(txbits,rxDataSoft);
    
    CodedBER(snri) = berSoft(1);
end

%Plot the non-coded of QPSK
figure(1)
semilogy(SNR_vector.',[BER CodedBER])
title('Coded vs. Non-coded QPSK')
legend('Uncoded','Convolutional Coded');
xlabel('SNR (dB)')
ylabel('BER')

%Plot the coded version of QPSK
% figure(2)
% semilogy(SNR_vector.', CodedBER)
% title('Coded QPSK')
% xlabel('SNR (dB)')
% ylabel('BER')