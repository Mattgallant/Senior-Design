%Adapted from Matlab Example: https://www.mathworks.com/help/comm/gs/use-pulse-shaping-on-16-qam-signal.html
%Pulse Shapes 4QAM (QPSK), 16QAM, and 64QAM signals
%FUTURE FUNCTIONALITY: Uses different encodings

%Data properties
N = 3e5; % Number of bits to process

%Filter properties
oversampling_factor = 4; % Number of samples per symbol (oversampling factor)
span = 10; % Filter length in symbols
rolloff = 0.5; % Filter rolloff factor

%Creating the filter
rrc_filter = rcosdesign(rolloff,span,oversampling_factor);

%Visualizing the filter impulses
fvtool(rrc_filter,'Analysis','Impulse')
h = fvtool(rrc_filter,'Analysis','freq')
%h.Fs = 1000;
%h.FrequencyRange='[-Fs/2, Fs/2)';

%EbNo Range
EbNo = -2:0.5:20;

%Encoding Properties
code_rate = 1/3;

%Init. Turbo encoder and decoder
%turboEncoder = comm.TurboEncoder('InterleaverIndicesSource','Input port');
%turboDecoder = comm.TurboDecoder('InterleaverIndicesSource','Input port','NumIterations',4);

%Interleaver indices for turbo encoding
 %intrlvrInd = randperm(N);

%BER (Bit Error Rate) collection arrays
BER_QPSK = zeros(1,length(EbNo));
BER_16QAM = zeros(1,length(EbNo));
BER_64QAM = zeros(1,length(EbNo));
unf_BER_QPSK = zeros(1,length(EbNo));
unf_BER_16QAM = zeros(1,length(EbNo));
unf_BER_64QAM = zeros(1,length(EbNo));

%Modulation Order Loop
for mod_order = 1:3
    
    %Modulation properties
    M = 2^(mod_order*2); %Modulation order e.g. 4, 16, 64
    k = log2(M);
    
    %Loop thorugh EbNo range for specified M (modulation order)
    for i = 1:length(EbNo)
        
        %Use default random number generator
        rng default; 
        
        %Generate vector of binary data 
        data = randi([0 1],N,1); 
        
        %Turbo encode the data_in
        %data_enc = step(turboEncoder, data, intrlvrInd);
        
        %Prepare for modulation using numbers rather than binary
        %Reshape data into binary 4-tuples
        data_matrix = reshape(data,length(data)/k,k); 
        %Convert to integers
        data_dec = bi2de(data_matrix); 
        
        %Modulate prepared data
        data_mod = qammod(data_dec,M);
        
        %Upsample and filter
        fitered_signal = upfirdn(data_mod,rrc_filter,oversampling_factor,1);
        nonfiltered_signal = data_mod;
        
        %Calculate snr
        %snr = EbNo(i) + 10*log10(k) - 10*log10(oversampling_factor);
        %snr_unc = EbNo(n) + 10*log10(k*rate_unc);
        snr = 10^(EbNo(i)/10)*code_rate*log2(M);
        
        %"Transmit" signal through AWGN channel
        recieved_signal = awgn(fitered_signal,snr,'measured');
        unf_recieved_signal = awgn(nonfiltered_signal,snr,'measured');
        
        %Unfilter signal and Account for filter delay
        unfiltered_signal = upfirdn(recieved_signal,rrc_filter,1,oversampling_factor);
        unfiltered_signal = unfiltered_signal(span + 1:end - span);
        
        %Demodulate data
        recieved_data_demod = qamdemod(unfiltered_signal,M);
        unf_recieved_data_demod = qamdemod(unf_recieved_signal,M);
        
        %Change data from number to binary
        recieved_data_matrix = de2bi(recieved_data_demod,k);
        recieved_data = recieved_data_matrix(:);
        unf_recieved_data_matrix = de2bi(unf_recieved_data_demod,k);
        unf_recieved_data = unf_recieved_data_matrix(:);
        
        
        %LDPC Decode demodulated hard data
        %enc_decode = step(turboDecoder, -recieved_data, intrlvrInd);
        
        %Calculate BER (Bit Error Rate)
        [num_errors,ber] = biterr(data,recieved_data);
        [unf_num_errors,unf_ber] = biterr(data,unf_recieved_data);
            if (mod_order == 1)
                BER_QPSK(i) = ber;
                unf_BER_QPSK(i) = unf_ber;
            end
            if(mod_order == 2)
                BER_16QAM(i) = ber;
                unf_BER_16QAM(i) = unf_ber;
            end
            if(mod_order == 3)
                BER_64QAM(i) = ber;
                unf_BER_64QAM(i) = unf_ber;
            end
    end
end

%Graph BER vs EbNo
figure(1)
semilogy(EbNo,BER_QPSK,'-b*')
hold on
semilogy(EbNo,BER_16QAM,'-r*')
hold on
semilogy(EbNo,BER_64QAM,'-g*')
hold on
semilogy(EbNo,unf_BER_QPSK,'-b')
hold on
semilogy(EbNo,unf_BER_16QAM,'-r')
hold on
semilogy(EbNo,unf_BER_64QAM,'-g')
legend('SRRC QPSK','SRRC 16QAM','SRRC 64QAM','Non Filtered QPSK','Non Filtered 16QAM','Non Filtered 64QAM','location','best')
title('BER vs EbNo for SRRC Filtered and Non Filtered QAM Mappings');
grid
xlabel('Eb/No')
ylabel('BER')
