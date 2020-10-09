rolloff = 0.25;
span = 10;
sps = 6;
M = 16;
k = log2(M);
pktlen = 2000;

rrcFilter = rcosdesign(rolloff, span, sps);

data = randi([0 1],pktlen, 1);

turboEnc = comm.TurboEncoder('InterleaverIndicesSource','Input port');
turboDec = comm.TurboDecoder('InterleaverIndicesSource','Input port','NumIterations',4);

intrlvrInd = randperm(pktlen);

encoded_data = turbo_encoding(data);%turboEnc(data,intrlvrInd);

bpskmod = comm.BPSKModulator;
bpskdemod = comm.BPSKDemodulator;
modData = bpskmod(encoded_data);%qammod(encoded_data,M,'InputType','bit','UnitAveragePower',true);

txSig = upfirdn(modData, rrcFilter, sps);

%EbNo = 7;
%snr = EbNo + 10*log10(k) - 10*log10(sps);
%rxSig = awgn(txSig, snr, 'measured');

rxFilt = upfirdn(txSig, rrcFilter, 1, sps);
rxFilt = rxFilt(span+1:end-span);

unmodData = bpskdemod(rxFilt);%qamdemod(modData,M,'UnitAveragePower',true,'OutputType','bit');

decoded_data = TurboDecoding(unmodData);%turboDec(unmodData,intrlvrInd);

length(decoded_data)

[number, ratio] = biterr(data, decoded_data);
disp(number);
