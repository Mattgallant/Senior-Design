%Description: Tests the functionality of a SRRC filter and match filter along combined with AGC. 
%This is the main file for this experiment. Uses BPSK

%% USER DEFINED BITSTREAM PARAMETERS

% read_length: number of chars to read from the file
read_length = 1000000;

%% USER DEFINED MODULATION PARAMETERS
%For this experiment, we will currently be just testing BPSK & 4PAM

%Modulation Type: 'BPSK' || '4PAM' || '8PAM' || 'QAM'
%   QAM: Quadrature Amplitude Modulation (16 || 64)
%   QPSK: Quadrature Phase Shift Keying
%   BPSK: Binary Phase Shift Keying
%   4PAM: Pulse Amplitude Modulation, modulation order 4
modulation_type = '8PAM';               %%Unused
modulation_vector = ["BPSK", "4PAM"];

%% Signal to Noise Ratio Test Values
%IF SNR_input_type = 'SNR_vector'
%   SNR_vector: define SNR values with range and step size
SNR_vector = -5:.2:40;
snr_vector = 10.^(SNR_vector/10); %natural units

%IF SNR_input_type = 'EbNo'
%   EbNo: define EbNo range with step size of 1
EbNo = (0:12)';

%% BER Rate Vector and Gain Error
iterationNumber = 3;           %Raise this number to get a more accurate mean squared error for gain
filterBer_vector = zeros(length(modulation_vector), length(SNR_vector));
ber_vector = zeros(length(modulation_vector), length(SNR_vector));
gainError_vector = zeros(iterationNumber, length(SNR_vector));

%% USER DEFINED ATTENTUATION PARAMETERS
gainFactor = 1;

%% USER DEFINED AGC PARAMETERS
%AGC Algo: 'grad' || 'lms'
AGC_algo = 'grad';

%% USER DEFINED TRAINING SEQUENCE PARAMETERS
%Training Algo: 'golay' || 'pn'

training_algo = 'golay';
sequence_length = 128;

%% SIMULATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is where the simulation takes place. 

%% Bitstream Generation (Jaino)
% Generates a bitstream from a file.
% Input: (numberOfBits) --> use read_length parameter
% - numberOfBits (must be a multiple of both 2 and 3)
% Output: [sourceCharacters, sendableBits]
% - soruceCharacters: 2D Matrix of ASCII values
% - sendableBits: The resulting bitstream
[sourceCharacters, sendableBits] = Input(read_length);

for modulation_index = 1:iterationNumber
    if modulation_index < 3
        modulation_type = modulation_vector(modulation_index);
        %% Signal Modulation (Jaino)
        % Modulates the input signal using a given modulation scheme. takes
        % sourceWithTrainingSignal and modulates
        % [BPSKSignal,FourPamSignal,EightPamSignal] = Modulation(sendableBits)
        % Input: TODO
        % - sendableBits: Vector of bits to be modulated
        % Output:
        % - BPSKSignal
        % - FourPamSignal
        % - EightPamSignal
        [BPSKSignal,FourPamSignal, EightPamSignal] = Modulation(sendableBits);
        switch modulation_type
            case 'BPSK'
                modulatedSignal = BPSKSignal;
            case '4PAM'
                modulatedSignal = FourPamSignal;
            otherwise 
                modulatedSignal = BPSKSignal;
        end
    end

    %% Training Sequence Injection (Austin, Carolyn)
    % Embeds the training sequence to the bit stream at the beginning of the data bits
    % Input: (modulatedSignal)
        % - modulatedSignal: Input stream signal
    % Output: (sourceWithTrainingSignal, training_sequence)
        % - sourceWithTrainingSignal: bitsream with embedded sequence\
    switch training_algo
        case 'golay'
            % Input: (sendableBits,loc)
            % - sendableBits: Input stream signal
            % Output: (sourceWithTrainingSignal, training_sequence)
            % - sourceWithTrainingSignal: bitsream with embedded sequence
            % - training_sequence: Pseudonoise training_sequence
           [sourceWithTrainingSignal, training_sequence] =  golay_sequence_generation(modulatedSignal, sequence_length);
        case 'pn'
            % Input: (sendableBits,loc)
            % - sendableBits: Input stream signal
            % Output: (sourceWithTrainingSignal, training_sequence)
            % - sourceWithTrainingSignal: bitsream with embedded sequence
            % - training_sequence: Pseudonoise training_sequence
           [sourceWithTrainingSignal, training_sequence] =  Embed_PNSequence(modulatedSignal);
        otherwise
           [sourceWithTrainingSignal, training_sequence] =  golay_sequence_generation(modulatedSignal, sequence_length);
    end
    
    %% Pulse Shaping and Upsampling
    %Filter properties
    oversampling_factor = 4; % Number of samples per symbol (oversampling factor)
    span = 10; % Filter length in symbols
    rolloff = 0.25; % Filter rolloff factor

    %Creating the filter
    rrc_filter = rcosdesign(rolloff,span,oversampling_factor);
    
    %Upsample and filter
    filteredSignal = upfirdn(sourceWithTrainingSignal,rrc_filter,oversampling_factor,1);
    
    %% Noise and Receiver Loop
    %For loop is here because it allows us to test multiple different SNR
    %values. It starts here b/c SNR values only affect noise in the channel,
    %transmitter doesn't need to be in the for loop.
    for index=1:length(SNR_vector)
        %% SIGNAL NOW TRANSMITTED, Channel Attentuation and Noise addition
        % In the channel, the attentuation factor will effect both the noise and
        % the original data itself. Corrected for attenuation factor noise will be
        % added to the signal that will be received on the other side.

        %Multiply the signal by the gain factor
        filterGainSignal = filteredSignal*gainFactor;
        gainSignal = sourceWithTrainingSignal*gainFactor;

        %Add AWGN based on the SNR and Attenuation Factor!
        SNR = (gainFactor^2)*snr_vector(index);           %New SNR w/ gain factor
        
        receivedPower = mean(abs(gainSignal).^2);
        receivedSignal = gainSignal + sqrt(receivedPower/SNR)*randn(1,length(gainSignal));
        
        %Repeat for filtered signal
        filterReceivedPower = mean(abs(filterGainSignal).^2);
        filterReceivedSignal = filterGainSignal + sqrt(filterReceivedPower/SNR)*randn(1,length(filterGainSignal));

        %% Match Filtering
        
        %Unfilter signal and Account for filter delay
        filteredReceivedSignal = upfirdn(filterReceivedSignal,rrc_filter,1,oversampling_factor);
        filteredReceivedSignal = filteredReceivedSignal(span + 1:end - span);
        
        %% Training Sequence Detection (Austin and Carolyn)
        % Detects the corresponding training sequence (golay or pn), outputs the
        % training sequence and outputs the rest of the exclusively received data
        % bits.
        % Input: (receivedSignal)
        % - receivedSignal: The noisy signal passed through the channel
        % - trainingSequence: Generated training sequence (golay or pn)
        % Output: [trainingSequence, receivedDataSignal]
        % - trainingSequence: The detected training sequence that will be used in AGC
        % - receivedDataSignal: the rest of the signal (the data)
        switch training_algo
            case 'golay'
                % Input: (training_sequence, gainControlledSignal)
                % - gainControlledSignal: amplitude equalized signal
                % - trainging_sequence: Generated golay sequence
                % Output: void
               [filteredNoisyTSequence, filteredReceivedDataSignal] = golay_sequence_detection(filteredReceivedSignal, sequence_length);
               [noisyTSequence, receivedDataSignal] = golay_sequence_detection(receivedSignal, sequence_length);
            case 'pn'
                % Input: (receivedSignal)
                % - receivedSignal: noisy signal passed through the channel
                % Output: (trainingSequence, receivedDataSignal
                % - training_sequence: detected PN training sequence that will be used in AGC
                % - receivedDataSignal: the rest of the signal (the data)
                [filteredNoisyTSequence, filteredReceivedDataSignal] = PNSequence_detection(filteredReceivedSignal);
                [noisyTSequence, receivedDataSignal] = PNSequence_detection(receivedSignal);
            otherwise
               [filteredNoisyTSequence, filteredReceivedDataSignal] = golay_sequence_detection(filteredReceivedSignal, sequence_length);
               [noisyTSequence, receivedDataSignal] = golay_sequence_detection(receivedSignal, sequence_length);
        end


        %% Automatic Gain Control (Phat and Joseph)
        % Use detected training sequence to estimate the gain factor. Then divide
        % that data signal by this factor to bring it back to (hopefully) right
        % amplitude level. 

        %-----AGC_Known_Function------
        %Stabilizes the amplitude of a received signal given that he original is
        %known
        %Inputs:    r - the signal to be equalized
        %           knownSignal - the known original signal
        %Outputs:   estimation - gain factor estimation   
        estimatedGain = AGC_Known_Function(noisyTSequence, training_sequence);
        gainControlledBits = receivedDataSignal/estimatedGain;

        gainErrorSquared = (gainFactor - estimatedGain)^2;
        gainError_vector(modulation_index, index) = gainErrorSquared;  %For plotting later
        
        %Repeat for filtered signal
        filterEstimatedGain = AGC_Known_Function(filteredNoisyTSequence, training_sequence);
        filterGainControlledBits = filteredReceivedDataSignal/filterEstimatedGain;

        %% Demodulate the data
        % Demodulates the data signal and assigns it to a final estimation of the
        % transmitted bits. Calculates the Bit Error Rate (Number of bit
        % errors/Total bits transmitted)
        if modulation_index < 4 %Only need to do this for the 3 modulations
            demodulatedBits =  Demodulation(modulation_type, gainControlledBits);
            [err,BER] = biterr(demodulatedBits(1:length(sendableBits)),sendableBits);
            ber_vector(modulation_index, index) = BER;  %For plotting later...
            
            %Repeat for filtered signal
            filterDemodulatedBits =  Demodulation(modulation_type, filterGainControlledBits);
            [err,BER] = biterr(filterDemodulatedBits(1:length(sendableBits)),sendableBits);
            filterBer_vector(modulation_index, index) = BER;  %For plotting later...
        end
    end
end

%% Plots (Matt)

%Calculate Mean of Gain Squared Error...
%gainMeanSquaredError = (gainError_vector(1, :) + gainError_vector(2, :) + gainError_vector(3,:))/iterationNumber;
gainMeanSquaredError = sum(gainError_vector(:, :))/iterationNumber;

% Gain Estimation vs SNR (Mean)
figure(1)
semilogy(SNR_vector, gainMeanSquaredError);
title("Gain Estimation Error (Mean of " + num2str(iterationNumber) + " trials)")
xlabel('SNR (dB)')
ylabel('Gain Estimate Error')
grid

% Gain Estimation vs SNR (No Mean)
figure(2)
semilogy(SNR_vector, gainError_vector(1, :));
title('Gain Estimation Error (no mean)')
xlabel('SNR (dB)')
ylabel('Gain Estimate Error')
grid

% BER vs SNR for BPSK, 4PAM, 8PAM
figure(3)
semilogy(SNR_vector.', ber_vector(1, :), '-b');
hold on
semilogy(SNR_vector.', ber_vector(2, :), '-g');
hold on
semilogy(SNR_vector.', filterBer_vector(1, :), '*b');
hold on
semilogy(SNR_vector.', filterBer_vector(2, :), '*g');
hold on
title("BER vs SNR for Filtered and Unfiltered BPSK & 4PAM");
legend('BPSK', '4PAM', 'Filtered BPSK', 'Filtered 4PAM')
grid
xlabel('SNR (dB)')
ylabel('BER')
