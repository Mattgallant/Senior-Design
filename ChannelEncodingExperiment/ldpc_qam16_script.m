clear; close all
%Sets random number generator to default settings
rng default
%Sets the QAM level (modulation order) to 16
M = 16;
%Sets the bits per symbol
k = log2(M);
%Sets Eb/No (db) range
EbNo = (2:10)';
%Init. LDPC encoder and decoder
ldpcEncoder = comm.LDPCEncoder;
ldpcDecoder_soft = comm.LDPCDecoder('DecisionMethod','Soft decision');
ldpcDecoder_hard = comm.LDPCDecoder('DecisionMethod','Hard decision');
%This program is adapted from https://www.mathworks.com/help/comm/ref/qamdemod.html
%MATLAB's example uses frames per SNR value to aggregate more data
%Sets symbols per frame
sym_frame = 8100;
%Inits. BER vectors
BER_soft = zeros(size(EbNo));
BER_hard = zeros(size(EbNo));
BER_unc_hard = zeros(size(EbNo));
%Set bitrate
rate = 1/2;
snr = 0.25;
%Main loop iterating through snr_range values
for n = 1 : length(EbNo)
    %Convert Eb/No EbNo to SNR 
    snr = EbNo(n) + 10*log10(k*rate);
    %Use simple snr increments
    %snr = snr + 0.25;
    %Calculate noise variance for unit power
    noiseVar = 10.^(-snr/10);
    %Reset error counters for use in a new snr iteration
    [numErrsSoft,numErrsHard,numErrsUncHard,num_bits] = deal(0);
    %Loop until a bit threshold per snr value is reached
    while num_bits < 1e5
        % Generate binary data and convert to symbols
        data_in = randi([0 1],sym_frame*k,1); 
        %LDPC encode the data_in
        data_enc = ldpcEncoder(data_in);
        %Modulate encoded data data_enc using 16-QAM (default: gray coding)
        data_mod = qammod(data_enc,M,'InputType','bit','UnitAveragePower',true);
        %Modulate unencoded data data_in using 16-QAM
        unc_data_mod = qammod(data_in,M,'InputType','bit','UnitAveragePower',true);
        %Pass modulated data data_mod through AWGN channel
        channel = awgn(data_mod,snr,'measured');
        unc_channel = awgn(unc_data_mod,snr,'measured');
        %Demodulate the channel using hard-decision
        %Output: bit
        r_data_hard = qamdemod(channel,M,'OutputType','bit','UnitAveragePower',true);
        r_unc_data_hard = qamdemod(unc_channel,M,'OutputType','bit','UnitAveragePower',true);
        %Demodulate the channel using soft-decision
        %Output: log-likelyhood ratio (llr)
        r_data_soft = qamdemod(channel,M,'OutputType','approxllr', ...
            'UnitAveragePower',true,'NoiseVariance',noiseVar);
        %LDPC Decode demodulated hard data
        r_data_hard_decode = ldpcDecoder_hard(r_data_hard);
        %LDPC Decode demodulated soft data
        r_data_soft_decode = ldpcDecoder_hard(r_data_soft);
        %Calculate bit error in the specified frame
        num_err_hard = biterr(data_in,r_data_hard_decode);
        num_err_soft = biterr(data_in,r_data_soft_decode);
        num_err_unc_hard = biterr(data_in,r_unc_data_hard);
        %Increment bit and bit error counters
        numErrsHard = numErrsHard + num_err_hard;
        numErrsSoft = numErrsSoft + num_err_soft;
        numErrsUncHard = numErrsUncHard + num_err_unc_hard;
        num_bits = num_bits + sym_frame*k; 
    end
    %Estimate BER for hard and soft decision making
    BER_soft(n) = numErrsSoft/num_bits;
    BER_hard(n) = numErrsHard/num_bits;
    BER_unc_hard(n) = numErrsUncHard/num_bits;
end
%Plot data
semilogy(EbNo,[BER_soft BER_hard],'-*')
hold on
semilogy(EbNo,BER_unc_hard)
hold on
semilogy(EbNo,berawgn(EbNo,'qam',M))
legend('Soft','Hard','Uncoded','Generic Uncoded','location','best')
grid
xlabel('Eb/No (dB)')
ylabel('Bit Error Rate')


