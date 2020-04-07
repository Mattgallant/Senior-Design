%Implementation of Turbo code using 16-QAM
% source: https://www.mathworks.com/help/comm/ug/estimate-turbo-code-ber-performance-in-awgn.html
%Modulation order (16-QAM)
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
rng default;
data = randi([0 1], n, 1);

%Init. Turbo encoder and decoder
turboEnc = comm.TurboEncoder('InterleaverIndicesSource','Input port');

turboDec = comm.TurboDecoder('InterleaverIndicesSource','Input port', ...
    'NumIterations',4);
intrlvrInd = randperm(n);

%Init. channel
awgnChannel = comm.AWGNChannel('NoiseMethod','Variance','Variance',1);
errorRate = comm.ErrorRate;

% Turbo encode the data
encodedData = turboEnc(data,intrlvrInd);
% Modulate encoded data
modSignal_encoded = qammod(encodedData,M,'InputType','bit','UnitAveragePower',true);
modSignal_uncoded = qammod(data,M,'InputType','bit','UnitAveragePower',true);

%Loop through the different SNR values
for ii = 1 : length(snr)
    noiseVar = 1./10.^(snr(ii)/10);
    
    %Pass signal through AWGN Channel
    chSignal_encoded = awgnChannel(modSignal_encoded);
    chSignal_uncoded = awgnChannel(modSignal_uncoded);
    
    %Demodulate recived signal
    demod_encoded = qamdemod(chSignal_encoded,M,'UnitAveragePower',true,'OutputType','llr','NoiseVariance',noiseVar);
    demod_uncoded = qamdemod(chSignal_uncoded,M,'UnitAveragePower',true,'OutputType','bit','NoiseVariance',noiseVar);
  
    %Decode demodulated 
    message_decode = turboDec(-demod_encoded, intrlvrInd);
    
    errorStats = errorRate(data,message_decode);
    
    %Calculate local and total bit error 
    num_err = biterr(data,double(message_decode));
    
    %total_err = total_err + num_err;
    unc_num_err = biterr(data,double(demod_uncoded));
    
    %unc_total_err = unc_total_err + unc_num_err;
    error_rate(ii) = num_err /n;
    unc_error_rate(ii) = unc_num_err /n;
end

%Plot BER vs. SNR for TurboCode
plot(snr,unc_error_rate,snr,error_rate);
legend('Uncoded','Turbo Coded');
xlabel('SNR (db)');
ylabel('BER');
