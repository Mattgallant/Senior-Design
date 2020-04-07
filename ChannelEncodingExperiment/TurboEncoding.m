M = 16;
%Bits per symbol
k = log2(M);
%Number of bits 
n = 32400;
%Number of samples per symbol
L = 1;
%SNR valuees to test
snr = (2:0.5:4);
%snr = [0.25,0.5,0.75,1.0,1.25];
%Error rate variables
error_rate = zeros(1,length(snr));
unc_error_rate = zeros(1,length(snr));
%Generate random data (binary)
%rng default;
data = randi([0 1], n, 1);
%Init. Turbo encoder and decoder
EbNo= -6;
frmLen = 256;
rng default
noiseVar = 10^(-EbNo/10);
intrlvrIndices = randperm(frmLen);
hTEnc = comm.TurboEncoder('TrellisStructure',poly2trellis(4,[13 15 17],13),'InterleaverIndices',intrlvrIndices);
hTDec = comm.TurboDecoder('TrellisStructure',poly2trellis(4,[13 15 17],13),'InterleaverIndices',intrlvrIndices,'NumIterations',4);
intrlvrInd = randperm(n);
hChan = comm.AWGNChannel('EbNo',EbNo);
hError = comm.ErrorRate;
hMod = comm.QPSKModulator;
hDemod = comm.QPSKDemodulator('DecisionMethod','Log-likelihood ratio','Variance',noiseVar);
%Init. channel
awgnChannel = comm.AWGNChannel('NoiseMethod','Variance','Variance',1);
errorRate = comm.ErrorRate;
% Turbo encode the data
encodedData = hTEnc(data);
% Modulate encoded data
modSignal_encoded = qammod(encodedData,M,'InputType','bit','UnitAveragePower',true);
%Loop through the different SNR values
for frmIdx = 1:100
    data = randi([0 1],frmLen,1);
    encodedData = step(hTEnc,data);
    modSignal = step(hMod,encodedData);
    receivedSignal = step(hChan,modSignal);
    demodSignal = step(hDemod,receivedSignal);
    receivedBits = step(hTDec,-demodSignal);
    errorStats = step(hError,data,receivedBits);
end

%Plot BER vs. SNR for TurboCode
plot(snr,unc_error_rate,snr,error_rate);
legend('Uncoded','Turbo Coded');
xlabel('SNR (db)');
ylabel('BER');