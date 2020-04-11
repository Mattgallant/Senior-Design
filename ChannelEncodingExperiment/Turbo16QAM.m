function BER_unc = Turbo16QAM(EbNo,frameNum)

    %Sets the QAM level (modulation order) to 16
    M = 16;

    %Sets the bits per symbol
    k = log2(M);

    frmLen = 1000*k;
    %Inits. BER vectors
    BER_enc = zeros(size(EbNo));
    BER_unc = zeros(size(EbNo));
    %Set bitrate
    rate_unc = 1;
    rate_enc = 1/3;

    %Init. Turbo encoder and decoder
    turboEncoder = comm.TurboEncoder('InterleaverIndicesSource','Input port');

    turboDecoder = comm.TurboDecoder('InterleaverIndicesSource','Input port', ...
        'NumIterations',4);

    % initialize error rate to measure BER
    enc_Error = comm.ErrorRate;
    unc_Error = comm.ErrorRate;

    %Main loop iterating through snr_range values
    for n = 1 : length(EbNo)
        %Convert Eb/No EbNo to SNR 
        snr_unc = EbNo(n) + 10*log10(k*rate_unc);
        snr_enc = 10^(EbNo(n)/10)*rate_enc*log2(M);

        %Calculate noise variance for unit power
        noiseVar_unc = 1/(10.^(snr_unc/10));
        noiseVar_enc = 1/snr_enc;

        % interleaver indices for turbo encoding
        intrlvrInd = randperm(frmLen);

        % reset Error Rate for next EbNo value
        reset(enc_Error);
        reset(unc_Error)

        %Loop until a bit threshold per snr value is reached
        for frmIndx = 1:frameNum

            % Generate binary data and convert to symbols
            data_in = randi([0 1],frmLen,1); 

            %Turbo encode the data_in
            data_enc = step(turboEncoder, data_in, intrlvrInd);

            %Modulate encoded data data_enc using 16-QAM (default: gray coding)
            data_mod = qammod(data_enc,M,'InputType','bit');
            %Modulate unencoded data data_in using 16-QAM
            unc_data_mod = qammod(double(data_in),M,'InputType','bit');

            %Pass modulated data data_mod through AWGN channel
            channel = awgn(data_mod,snr_enc,'measured');
            unc_channel = awgn(unc_data_mod,snr_unc,'measured');

            %Demodulate the channel 
            enc_demod = qamdemod(channel,M,'OutputType','llr','NoiseVariance',noiseVar_enc);
            unc_demod = qamdemod(unc_channel,M,'OutputType','bit','NoiseVariance',noiseVar_unc);

            %LDPC Decode demodulated hard data
            enc_decode = step(turboDecoder, -enc_demod, intrlvrInd);

            % Calculate error stats
            encErrorStats = step(enc_Error,data_in,enc_decode);
            uncErrorStats = step(unc_Error,data_in,unc_demod);

        end
        %Estimate BER for coded and uncoded
        BER_enc(n) = encErrorStats(1);
        BER_unc(n) = uncErrorStats(1);
    end

end
