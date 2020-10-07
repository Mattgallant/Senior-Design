rolloff = 0.25;
span = 6;
sps = 4;
M = 16;
k = log2(M);
pktlen = 10000;

rrcFilter = rcosdesign(rolloff, span, sps);

data = randi([0 1],pktlen, 1);

turboEnc = comm.TurboEncoder('InterleaverIndicesSource','Input port');
turboDec = comm.TurboDecoder('InterleaverIndicesSource','Input port','NumIterations',4);

intrlvrInd = randperm(pktlen);

%encoded_data = turboEnc(data,intrlvrInd);

bpskmod = comm.BPSKModulator;
bpskdemod = comm.BPSKDemodulator;
modData = bpskmod(data);%qammod(encoded_data,M,'InputType','bit','UnitAveragePower',true);

txSig = upfirdn(modData, rrcFilter, sps);

%EbNo = 7;
%snr = EbNo + 10*log10(k) - 10*log10(sps);
%rxSig = awgn(txSig, snr, 'measured');

rxFilt = upfirdn(txSig, rrcFilter, 1, sps);
rxFilt = rxFilt(span+1:end-span);

unmodData = bpskdemod(modData);%qamdemod(modData,M,'UnitAveragePower',true,'OutputType','bit');

%decoded_data = turboDec(unmodData,intrlvrInd);

%length(decoded_data)

[number, ratio] = biterr(data, unmodData);
disp(number);
