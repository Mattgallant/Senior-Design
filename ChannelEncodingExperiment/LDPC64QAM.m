%code from https://www.mathworks.com/help/comm/ug/estimate-ldpc-performance-in-awgn.html
%pammod from https://www.mathworks.com/help/comm/ref/pammod.html

%clc, clear all, close all;

%function goes here
function returnedBER = LDPC64QAM(EbNo, frameNum)
% frameNum = 5;
% EbNo = (-2:0.25:10)';
%end of temp params


    ldpcEnc = comm.LDPCEncoder;
    ldpcDec = comm.LDPCDecoder;
    ldpcDecSoft = comm.LDPCDecoder('DecisionMethod','Soft decision');

    %setting modulation order
    M = 64;

    %Using Eb/No (db) range instead of snr vector
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

         numErr = 0;
         numErrSoft = 0;
         numErrUncoded = 0;

        for count = 1:frameNum
            % Generate binary data
            txbits = randi([0 1], 2*N, 1);    

            % Apply LDPC encoding
            encData = step(ldpcEnc, txbits);%ldpcEnc(logical(txbits));                

            % Modulate

            %Using qammod instead of by hand
            modSig =  qammod(double(encData),M,'InputType','bit','UnitAveragePower',true);  
            modSigUncoded = qammod(double(txbits),M,'InputType','bit','UnitAveragePower',true);

            % Define energy of transmitted signal
            Energy_modSig = mean(abs(modSig).^2);     
            Energy_modSigUncoded = mean(abs(modSigUncoded).^2);

            % Create noise signal and add it to received signal
            snr = 10.^(SNR/10);
            noise_var = 1/snr;   % snr = Energy_x/noise_var
            noise_varUncoded = 1/snr;   % snr = Energy_x/noise_var

            % Pass through AWGN channel
            %cave in and use the awgn function
            rxSig = awgn(modSig,SNR,'measured');
            rxSigUncoded = awgn(modSigUncoded,SNR,'measured');

            % Step 5: Convert received signal to bits

            %qamdemod demodulate (hard decision)
            rec_bits = qamdemod(rxSig,M,'OutputType','llr','UnitAveragePower',true,'NoiseVariance',noise_var);
            rec_bitsUncoded = qamdemod(rxSigUncoded,M,'OutputType','bit','UnitAveragePower',true,'NoiseVariance',noise_var);

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

            numErr = numErr + err;
            numErrSoft = numErrSoft + errSoft;
            numErrUncoded = numErrUncoded + errUncoded;

        end

        BER(k) = numErr/(frameNum * 2 * N);
        BERSoft(k) = numErrSoft/(frameNum * 2 * N);
        BERUncoded(k) = numErrUncoded/(frameNum * 2 * N);

    end
    
    returnedBER = BERSoft;
    
%     figure, semilogy(EbNo,BER)
%     hold on
%     semilogy(EbNo,BERSoft)
%     hold on
%     semilogy(EbNo,BERUncoded)
%     legend('Coded BER', 'Coded BER Soft', 'Uncoded BER')
%     xlabel('Eb/No (dB)')
%     ylabel('BER')
%     title('LDPC 64 QAM')
    
end

%inputs: number of frames, Eb/No range
%frame method 16QAM ldcp for more bits
%output: Eb/No and BERSoft



