function BER_soft = qpskLDPC(EbNo,frameNum)
    ldpcEncoder = comm.LDPCEncoder;
    ldpcDecoder = comm.LDPCDecoder;

    %Sets the PSK level (modulation order) to QPSK
    M = 4;
    %Sets the bits per symbol
    k = log2(M);

    %Init. BER vectors
    BER_unc_hard = zeros(size(EbNo));
    BER_soft = zeros(size(EbNo));

    %Coding rate
    codeRate = 1/2;

    %Data Length
    N = 32400;

    %Main loop iterating throughEbNo values
    for n = 1 : length(EbNo)
        %Reset error counters for use in a new snr iteration
        [numErrsSoft,numErrsUncHard] = deal(0);
        fprintf("%d\n",EbNo(n));

        %Loop until number of frames is reached
        for iterations = 1 : frameNum
            % Generate binary data and convert to symbols
            data_in = randi([0 1],N,1); 
            %LDPC encode the data_in
            data_enc = step(ldpcEncoder,data_in);
            %SNR
            snr = 10^(EbNo(n)/10)*codeRate*k;
            %Calculate noise variance for unit power
            noiseVar = 1/snr;
            
            qpskmod = comm.QPSKModulator('BitInput',true);
            qpskdemod = comm.QPSKDemodulator('BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio','Variance',noiseVar,'VarianceSource','Property');
            qpskdemod_b = comm.QPSKDemodulator('BitOutput',true);
             
            %Modulate the data using QPSK
            data_mod = qpskmod(data_enc);
            unc_data_mod = qpskmod(data_in);
            %Pass modulated data data_mod through AWGN channel
            channel = awgn(data_mod,snr,'measured');
            unc_channel = awgn(unc_data_mod,snr,'measured');
            %Demodulate data
            r_unc_data_hard = qpskdemod_b(unc_channel);
            %Output: log-likelyhood ratio (llr)
            r_data_soft = qpskdemod(channel);
             %LDPC Decode demodulated soft data
            r_data_soft_decode = step(ldpcDecoder,r_data_soft);
            %Calculate errors per frame
            num_err_soft = biterr(data_in,r_data_soft_decode);
            num_err_unc_hard = biterr(data_in,r_unc_data_hard);
            %Increment bit and bit error counters
            numErrsSoft = numErrsSoft + num_err_soft;
            numErrsUncHard = numErrsUncHard + num_err_unc_hard;
        end
        %Estimate BER for soft decision making
        BER_soft(n) = numErrsSoft/(frameNum*N);
        BER_unc_hard(n) = numErrsUncHard/(frameNum*N);   
    end

end

