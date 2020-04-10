% Implementation of Turbo Encoding using QPSK
clear; close all
rng default

% Sets the QAM level to 4 (QPSK)
M = 4;
k = log2(M);
EbNo = (-4:1:8)';
frmLen = 1000*k;
rate_enc = 1/3;
rate_unc = 1;

% BER for encoded and uncoded signal
BER_enc = zeros(size(EbNo));
BER_unc = zeros(size(EbNo));

%Main loop iterating through snr_range values
for n = 1 : length(EbNo)
    
    %Convert Eb/No EbNo to SNR 
    snr_unc = EbNo(n) + 10*log10(k*rate_unc);
    snr_enc = EbNo(n) + 10*log10(k*rate_enc);
  
    %Calculate noise variance for unit power
    noiseVar_unc = (10.^(snr_unc/10));
    noiseVar_enc = (10.^(snr_enc/10));
    
    % interleaver indices for turbo encoding
    intrlvrIndices = randperm(frmLen);
    
    % initializing turbo encoder and decoder
    hTEnc = comm.TurboEncoder('InterleaverIndicesSource','Input port');
    hTDec = comm.TurboDecoder('InterleaverIndicesSource','Input port','NumIterations',4);
    
    % initialize error rate to measure BER
    hError = comm.ErrorRate;
    
    fprintf("%d\n",noiseVar_unc);
    fprintf("%d\n",noiseVar_enc);
    
    % loop over 100 frames
    for frmIdx = 1:100
        
        % generate bit sequence
        data = randi([0 1],frmLen,1);
        
        % encoded
        encodedData = step(hTEnc,data,intrlvrIndices);
        modSignal = qammod(encodedData,M,'InputType','bit');
        receivedSignal = awgn(modSignal,snr_enc,'measured');
        demodSignal = qamdemod(receivedSignal,M,'OutputType','llr','NoiseVariance',noiseVar_enc);
        receivedBits = step(hTDec,-demodSignal,intrlvrIndices);
        encErrorStats = step(hError,data,receivedBits);
        
        % uncoded
        uncModSignal = qammod(double(data),M,'InputType','bit');
        uncReceivedSignal = awgn(uncModSignal,snr_unc,'measured');
        uncDemod = qamdemod(uncReceivedSignal,M,'OutputType','bit','NoiseVariance',noiseVar_unc);
        uncErrorStats = step(hError,data,uncDemod);
    end
    BER_enc(n) = encErrorStats(1);
    BER_unc(n) = uncErrorStats(1);
end
%Plot data
semilogy(EbNo,BER_enc,'-*')
hold on
semilogy(EbNo,BER_unc, '-o')
hold on
semilogy(EbNo,berawgn(EbNo,'qam',M),  '-+')
legend('Encoded','Uncoded','Generic Uncoded','location','best')
grid
xlabel('Eb/No (dB)')
ylabel('Bit Error Rate')
