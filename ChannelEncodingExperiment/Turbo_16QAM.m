%Implementation of Turbo code using 16-QAM
% source: https://www.mathworks.com/help/comm/ug/estimate-turbo-code-ber-performance-in-awgn.html
clear; close all
%Sets random number generator to default settings
rng default
%Sets the QAM level (modulation order) to 16
M = 16;
%Sets the bits per symbol
k = log2(M);
%Sets Eb/No (db) range
EbNo = (0:12)';
%Init. Turbo encoder and decoder
turboEncoder = comm.TurboEncoder('InterleaverIndicesSource','Input port');

turboDecoder = comm.TurboDecoder('InterleaverIndicesSource','Input port', ...
    'NumIterations',4);

%Sets symbols per frame
%Where does this value come from?
sym_frame = 8100;
%Inits. BER vectors
BER_enc = zeros(size(EbNo));
BER_unc = zeros(size(EbNo));
%Set bitrate
rate_unc = 1;
rate_enc = 1/3;

%Main loop iterating through snr_range values
for n = 1 : length(EbNo)
    %Convert Eb/No EbNo to SNR 
    snr_unc = EbNo(n) + 10*log10(k*rate_unc);
    snr_enc = EbNo(n) + 10*log10(k*rate_enc);
  
    %Calculate noise variance for unit power
     noiseVar_unc = (10.^(snr_unc/10));
     noiseVar_enc = (10.^(snr_enc/10));
     
    %Reset error counters for use in a new snr iteration
    [numErrsEnc,numErrsUnc,num_bits] = deal(0);
    %Loop until a bit threshold per snr value is reached
    while num_bits < 1e5
        % Generate binary data and convert to symbols
        data_in = randi([0 1],sym_frame*k,1); 
        
        intrlvrInd = randperm(sym_frame*k);
        
        %Turbo encode the data_in
        %data_enc = turboEncoder(data_in,intrlvrInd);
        data_enc = step(turboEncoder, data_in, intrlvrInd);
         
        %Modulate encoded data data_enc using 16-QAM (default: gray coding)
        data_mod = qammod(data_enc,M,'InputType','bit');
        %Modulate unencoded data data_in using 16-QAM
        unc_data_mod = qammod(double(data_in),M,'InputType','bit');
        
        %Pass modulated data data_mod through AWGN channel
        channel = awgn(data_mod,snr_enc,'measured');
        unc_channel = awgn(unc_data_mod,snr_unc,'measured');
    
        %Demodulate the channel 
        %enc_demod = qamdemod(channel,M,'OutputType','llr','NoiseVariance',noiseVar_enc);
        %unc_demod = qamdemod(unc_channel,M,'OutputType','bit','NoiseVariance',noiseVar_unc);
        enc_demod = qamdemod(channel,M,'OutputType','llr','NoiseVariance',noiseVar_enc);
        unc_demod = qamdemod(unc_channel,M,'OutputType','bit','NoiseVariance',noiseVar_unc);
  
        %LDPC Decode demodulated hard data
        enc_decode = step(turboDecoder, enc_demod, intrlvrInd);
        
        %Calculate bit error in the specified frame
        num_err_enc = biterr(data_in,enc_decode);
        num_err_unc = biterr(data_in,unc_demod);
        %Increment bit and bit error counters
        numErrsEnc = numErrsEnc + num_err_enc;
        numErrsUnc = numErrsUnc + num_err_unc;
        num_bits = num_bits + sym_frame*k; 
    end
    %Estimate BER for coded and uncoded
    BER_enc(n) = numErrsEnc/num_bits;
    BER_unc(n) = numErrsUnc/num_bits;
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