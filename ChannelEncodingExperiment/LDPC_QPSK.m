
ldpcEnc = comm.LDPCEncoder;
ldpcDec = comm.LDPCDecoder;

qpskMod = comm.QPSKModulator('BitInput',true);
qpskDemod = comm.QPSKDemodulator('BitOutput',true,...
    'DecisionMethod','Approximate log-likelihood ratio', ...
    'VarianceSource','Input port');
errorCnt = comm.ErrorRate;

snrVec = 0:0.07:0.8;
ber = zeros(length(snrVec),1);

for k = 1:length(snrVec)
    noiseVar = 1/10^(snrVec(k)/10);
    errorStats = zeros(1,3);
    while errorStats(2) <= 200 && errorStats(3) < 1e5
        data = logical(randi([0 1],32400,1));   % Generate binary data
        encData = ldpcEnc(data);                % Apply LDPC encoding
        modSig = qpskMod(encData);              % Modulate
        rxSig = awgn(modSig,snrVec(k));         % Pass through AWGN channel
        demodSig = qpskDemod(rxSig,noiseVar);   % Demodulate
        rxData = ldpcDec(demodSig);             % Decode LDPC
        errorStats = errorCnt(data,rxData);     % Compute error stats
    end
    
    % Save the BER for the current Eb/No and reset the error rate counter
    ber(k) = errorStats(1);
    reset(errorCnt)
end

semilogy(snrVec.',ber)
grid
xlabel('SNR (dB)')
ylabel('Bit Error Rate')
