% Convolutional QPSK. This script simulates both an uncoded QPSK
% transmition and a coded version using convolutional code with rate 1/3.
clc, clear all, close all;

%Create vectors that will be used to plot and generate data
SNR_vector = -2:.20:7;                                    %Start:StepSize:End
%SNR_vector = 2;
CodedBER = zeros(length(SNR_vector),1);
BER = zeros(length(SNR_vector),1);

N = 1000000;                                             %Size of the bitstream

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

% _Simulation parameters_
M = 4;
k = log2(M);

%%
% _Code properties_
codeRate = 1/2;
constLen = 7;
codeGenPoly = [171 133];
tblen = 32;     
trellis = poly2trellis(constLen,codeGenPoly);

%% 
% Create a rate 1/2, constraint length 7 |<docid:comm_ref#bsnfrdn_3
% ConvolutionalEncoder>| System object(TM).
enc = comm.ConvolutionalEncoder(trellis);

qpskMod = comm.QPSKModulator('BitInput',true);
demodLLR = comm.QPSKDemodulator('BitOutput',true,...
    'DecisionMethod','Log-likelihood ratio');

for snri = 1:length(SNR_vector)
    SNR = SNR_vector(snri);                             % SNR in decibels
    EbNo = SNR_vector(snri);                            % SNR = EbNo here... 1/2 code rate and 2 bits per symbol
    
    chan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (Eb/No)', ...
        'BitsPerSymbol',k);
    EbNoCoded = EbNo + 10*log10(codeRate);
    chan.EbNo = EbNoCoded;

    % *Viterbi Decoding*
    decSoft = comm.ViterbiDecoder(trellis,'InputFormat','Soft', ...
        'SoftInputWordLength',3,'TracebackDepth',tblen); 

    % *Quantization for soft-decoding*
    scalQuant = dsp.ScalarQuantizerEncoder('Partitioning','Unbounded');
    snrdB = EbNoCoded + 10*log10(k);
    NoiseVariance = 10.^(-snrdB/10);
    demodLLR.Variance = NoiseVariance;
    scalQuant.BoundaryPoints = (-1.5:0.5:1.5)/NoiseVariance;

    % *Calculating the Error Rate*
    errSoft = comm.ErrorRate('ReceiveDelay',tblen);

    %% System Simulation
    txData = randi([0 1],2*N,1);
    % Convolutionally encode the data.
    encData = enc(txData); 
    % Modulate the encoded data.
    modData = qpskMod(encData);
    % Pass the modulated signal through an AWGN channel.
    rxSig = chan(modData);
    % Demodulate the received signal and output LLR values.
    LLRData = demodLLR(rxSig);
    % Pass the demodulated data to the quantizer. This data must be multiplied
    % by |-1| before being passed to the quantizer, because, in soft-decision
    % mode, the Viterbi. decoder assumes that positive numbers correspond to 1s
    % and negative numbers to 0s. Pass the quantizer output to the Viterbi
    % decoder. Compute the error statistics
    quantizedValue = scalQuant(-LLRData);
    rxDataSoft = decSoft(double(quantizedValue));
    berSoft = errSoft(txData,rxDataSoft);

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
figure(2)
semilogy(SNR_vector.', CodedBER)
title('Coded QPSK')
xlabel('SNR (dB)')
ylabel('BER')