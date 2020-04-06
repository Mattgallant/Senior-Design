M = 4;
k = log2(M);
bitsPerIter = 1.2e5;
EbNo_vector = 0:.01:3.5;
ber_vector = zeros(length(EbNo_vector), 1);
codeRate = 1/2;
constLen = 7;
codeGenPoly = [171 133];
tblen = 32;
trellis = poly2trellis(constLen,codeGenPoly);

enc = comm.ConvolutionalEncoder(trellis);

qpskMod = comm.QPSKModulator('BitInput',true);
demodLLR = comm.QPSKDemodulator('BitOutput',true,...
    'DecisionMethod','Log-likelihood ratio');

for i = 1:length(EbNo_vector)
    EbNo = EbNo_vector(i);
    chan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (Eb/No)', ...
        'BitsPerSymbol',k);
    EbNoCoded = EbNo + 10*log10(codeRate);
    chan.EbNo = EbNoCoded;

    decSoft = comm.ViterbiDecoder(trellis,'InputFormat','Soft', ...
        'SoftInputWordLength',3,'TracebackDepth',tblen);

    scalQuant = dsp.ScalarQuantizerEncoder('Partitioning','Unbounded');
    snrdB = EbNoCoded + 10*log10(k);
    NoiseVariance = 10.^(-snrdB/10);
    demodLLR.Variance = NoiseVariance;
    scalQuant.BoundaryPoints = (-1.5:0.5:1.5)/NoiseVariance;

    errHard = comm.ErrorRate('ReceiveDelay',tblen);
    errUnquant = comm.ErrorRate('ReceiveDelay',tblen);
    errSoft = comm.ErrorRate('ReceiveDelay',tblen);

    txData = randi([0 1],bitsPerIter,1);
    encData = enc(txData);
    modData = qpskMod(encData);
    rxSig = chan(modData);
    LLRData = demodLLR(rxSig);

    quantizedValue = scalQuant(-LLRData);
    rxDataSoft = decSoft(double(quantizedValue));
    berSoft = errSoft(txData,rxDataSoft);

    ber_vector(i) = berSoft(1);
end

figure(1)
semilogy(EbNo_vector, ber_vector);
title('Coded QPSK')
xlabel('Eb/No (dB)')
ylabel('BER')


