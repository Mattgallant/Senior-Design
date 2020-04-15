%!!!!!!!!!!!!! WIP !!!!!!!!!!!!!!!!!!!!!!!!
%code from https://www.mathworks.com/help/comm/ug/estimate-ldpc-performance-in-awgn.html
%pammod from https://www.mathworks.com/help/comm/ref/pammod.html

clc, clear all, close all;

ldpcEnc = comm.LDPCEncoder;
ldpcDec = comm.LDPCDecoder;
ldpcDecSoft = comm.LDPCDecoder('DecisionMethod','Soft decision');

%setting modulation order
M = 64;

% snrVec = 0:2:40;
% ber = zeros(length(snrVec),1);
% BER = zeros(length(snrVec),1);

%Using Eb/No (db) range instead of snr vector
EbNo = (-2:0.25:10)';
ber = zeros(size(EbNo));
BER = zeros(size(EbNo));
BERSoft = zeros(size(EbNo));
BERUncoded = zeros(size(EbNo));

%normalization factor
L = sqrt(1/42);

%number of bits
N = 32400/2;        %something with LDPC funtion's parameter requires this amount

for k = 1:length(EbNo)
    %get snr now from EbNo
    bps = log2(M);    %bits per symbol
    codeRate = 1/2;
    %SNR = EbNo(k) + 10*log10(bps);
    SNR = EbNo(k) * codeRate * bps;
    % Generate binary data
    
    txbits = randi([0 1], 2*N, 1);    
    
    % Apply LDPC encoding
    encData = step(ldpcEnc, txbits);%ldpcEnc(logical(txbits));                
   
    % Modulate
%     dataConvert = double(encData).';
%     for i = 3:3:4*N
%             transData(i/3) = bi2de([dataConvert(i-2),dataConvert(i-1), dataConvert(i)]); %should be gray encoded
%     end
%     modSig = L*(((2*transData(1:2:end)-7)) + 1i*(2*transData(2:2:end)-7)).';   

    %Using qammod instead of by hand
    %modSig = qammod(double(encData),M,'gray'); % Gray coding with phase offset of zero
    modSig =  qammod(double(encData),M,'InputType','bit','UnitAveragePower',true);  %why can't gray code ;-;
    modSigUncoded = qammod(double(txbits),M,'InputType','bit','UnitAveragePower',true);
%scatterplot(modSig)
%scatterplot(modSigUncoded)

    % Define energy of transmitted signal
    Energy_modSig = mean(abs(modSig).^2);     
    Energy_modSigUncoded = mean(abs(modSigUncoded).^2);
    
    % Create noise signal and add it to received signal
    snr = 10^(EbNo(k)/10)*codeRate*log2(M);%10.^(SNR/10);
    noise_var = 1/snr;   % snr = Energy_x/noise_var
    noise_varUncoded = 1/snr;   % snr = Energy_x/noise_var
     
    % Pass through AWGN channel
%     noise = sqrt(noise_var/2)*(randn(N/3*2,1) + 1i*randn(N/3*2,1)); %!!!!!!!!!!!watch for size
%     %noise = sqrt(noise_varUncoded/2)*(randn(N/3*2,1) + 1i*randn(N/3*2,1)); %what if
%     noise_var_check = mean(abs(noise).^2);
%     noiseUncoded = sqrt(noise_varUncoded/2)*(randn(N/3,1) + 1i*randn(N/3,1)); %!!!!!!!!!!!watch for size
%     noise_var_checkUncoded = mean(abs(noiseUncoded).^2);
%     
%      rxSig = modSig + noise; 
%      rxSigUncoded = modSigUncoded + noiseUncoded; 

%     codeRate = 1/2;
%     chan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (Eb/No)', ...
%         'BitsPerSymbol',bps);
%     EbNoCoded = SNR + 10*log10(codeRate);
%     chan.EbNo = EbNoCoded;
%     
%      rxSig = chan(modSig);
%     rxSigUncoded = chan(modSigUncoded);
 
    %cave in and use the awgn function
    rxSig = awgn(modSig,snr,'measured');
    rxSigUncoded = awgn(modSigUncoded,snr,'measured');
    
%     SNR_check = 10*log10(Energy_modSig/noise_var_check);
%     SNR_checkUncoded = 10*log10(Energy_modSigUncoded/noise_var_checkUncoded);
%      scatterplot(rxSig)
%   scatterplot(rxSigUncoded)

    % Step 5: Convert received signal to bits
    
    %qamdemod demodulate (hard decision)
    rec_bits = qamdemod(rxSig,M,'OutputType','llr','UnitAveragePower',true,'NoiseVariance',noise_var);
    rec_bitsUncoded = qamdemod(rxSigUncoded,M,'OutputType','bit','UnitAveragePower',true,'NoiseVariance',noise_var);
%scatterplot(rec_bits)
%scatterplot(rec_bitsUncoded)

    %qamdemod demodulate (soft decision)
    rec_bitsSoft = qamdemod(rxSig,M,'OutputType','approxllr','UnitAveragePower',true,'NoiseVariance',noise_var);
    
    
    % Decode LDPC
    rxData = step(ldpcDec, rec_bits);%ldpcDec(rec_bits); 
    rxDataSoft = step(ldpcDec, rec_bitsSoft);%ldpcDec(rec_bitsSoft); 
    
    % Compute Error
    rxDataUncoded = rec_bitsUncoded;
    %rxData = xor(rxDataHold,1); %for some reason a majority of bits are flipped???
    error_final = mean(abs(rxData - txbits).^2);
    error_finalUncoded = mean(abs(rxDataUncoded - txbits).^2);
    
    [err,ber] = biterr(rxData,txbits);
    [errSoft,berSoft] = biterr(rxDataSoft,txbits);
    [errUncoded,berUncoded]= biterr(rxDataUncoded,txbits);
    
    BER(k) = ber;
    BERSoft(k) = berSoft;
    BERUncoded(k) = berUncoded;
    
end

figure, semilogy(EbNo,BER)
hold on
semilogy(EbNo,BERSoft)
hold on
semilogy(EbNo,BERUncoded)
legend('Coded BER', 'Coded BER Soft', 'Uncoded BER')
xlabel('Eb/No (dB)')
ylabel('BER')
title('LDPC 64 QAM')

