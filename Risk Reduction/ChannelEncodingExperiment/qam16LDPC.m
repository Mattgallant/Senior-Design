function BER_soft  = qam16LDPC(EbNo,frames)
    %Sets the QAM level (modulation order) to 16
    M = 16;
    %Sets the bits per symbol
    k = log2(M);
    %Init. LDPC encoder and decoder
    ldpcEncoder = comm.LDPCEncoder;
    ldpcDecoder_hard = comm.LDPCDecoder;
    sym_frame = 8100;
    %Inits. BER vectors
    BER_soft = zeros(size(EbNo));
    BER_hard = zeros(size(EbNo));
    BER_unc_hard = zeros(size(EbNo));
    %Set bitrate
    rate = 1/2;
    %Main loop iterating through snr_range values
    for n = 1 : length(EbNo)
        %Reset error counters for use in a new snr iteration
        [numErrsSoft,numErrsHard,numErrsUncHard,num_bits] = deal(0);
        fprintf("%d\n",EbNo(n));
        %Loop until a bit threshold per snr value is reached
        for nn = 1 : frames
            % Generate binary data and convert to symbols
            data_in = randi([0 1],sym_frame*k,1); 
            %LDPC encode the data_in
            data_enc = step(ldpcEncoder,data_in);
            %SNR
            snr = 10^(EbNo(n)/10)*rate*log2(M);
            SNR = EbNo(k) * rate * log2(M);
            %Calculate noise variance for unit power
            noiseVar = 1/snr; %1/(10.^(snr/10))
            %Modulate encoded data data_enc using 16-QAM (default: gray coding)
            data_mod = qammod(data_enc,M,'InputType','bit','UnitAveragePower',true);
            %Modulate unencoded data data_in using 16-QAM
            unc_data_mod = qammod(double(data_in),M,'InputType','bit','UnitAveragePower',true);
            %Pass modulated data data_mod through AWGN channel
            channel = awgn(data_mod,snr,'measured');
            unc_channel = awgn(unc_data_mod,snr,'measured');
            %Demodulate the channel using hard-decision
            %Output: bit
            r_data_hard = qamdemod(channel,M,'OutputType','llr','UnitAveragePower',true,'NoiseVariance',noiseVar);
            r_unc_data_hard = qamdemod(unc_channel,M,'OutputType','bit','UnitAveragePower',true,'NoiseVariance',noiseVar);
            %Demodulate the channel using soft-decision
            %Output: log-likelyhood ratio (llr)
            r_data_soft = qamdemod(channel,M,'OutputType','approxllr', ...
                'UnitAveragePower',true,'NoiseVariance',noiseVar);
            %LDPC Decode demodulated hard data
            r_data_hard_decode = step(ldpcDecoder_hard,r_data_hard);
            %LDPC Decode demodulated soft data
            r_data_soft_decode = step(ldpcDecoder_hard,r_data_soft);
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

end


