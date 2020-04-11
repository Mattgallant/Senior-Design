%Description: Tests the functionality of AGC. This is the main file for
%this experiment. All functions should be plugged into this file so it can
%be tested.

%% USER DEFINED BITSTREAM PARAMETERS

% read_length: number of chars to read from the file
read_length = 59968;

%% USER DEFINED MODULATION PARAMETERS
%For this experiment, we will currently be just testing BPSK, 4PAM & 8PAM

%Modulation Type: 'BPSK' || '4PAM' || '8PAM' || 'QAM'
%   QAM: Quadrature Amplitude Modulation (16 || 64)
%   QPSK: Quadrature Phase Shift Keying
%   BPSK: Binary Phase Shift Keying
%   4PAM: Pulse Amplitude Modulation, modulation order 4
modulation_type = 'BPSK';

%% Signal to Noise Ratio Test Values
%IF SNR_input_type = 'SNR_vector'
%   SNR_vector: define SNR values with range and step size
SNR_vector = 0:2:40;

%IF SNR_input_type = 'EbNo'
%   EbNo: define EbNo range with step size of 1
EbNo = (0:12)';

%% BER Rate Vector and Gain Error
ber_vector = zeros(1, length(SNR_vector));
gainError_vector = zeros(1, length(SNR_vector));

%% USER DEFINED ATTENTUATION PARAMETERS
gainFactor = 10;

%% USER DEFINED AGC PARAMETERS
%AGC Algo: 'grad' || 'lms'
AGC_algo = 'grad';

%% USER DEFINED TRAINING SEQUENCE PARAMETERS
%Training Algo: 'golay' || 'pn'

training_algo = 'golay';

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
    case '8PAM'
        modulatedSignal = EightPamSignal;
    otherwise 
        modulatedSignal = BPSKSignal;
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
       [sourceWithTrainingSignal, training_sequence] =  golay_sequence_generation(modulatedSignal);
    case 'pn'
        % Input: (sendableBits,loc)
        % - sendableBits: Input stream signal
        % Output: (sourceWithTrainingSignal, training_sequence)
        % - sourceWithTrainingSignal: bitsream with embedded sequence
        % - training_sequence: Pseudonoise training_sequence
       [sourceWithTrainingSignal, training_sequence] =  Embed_PNSequence(modulatedSignal);
    otherwise
       [sourceWithTrainingSignal, training_sequence] =  golay_sequence_generation(modulatedSignal);
end

%For loop is here because it allows us to test multiple different SNR
%values. It starts here b/c SNR values only affect noise in the channel,
%transmitter doesn't need to be in the for loop.
for index=1:length(SNR_vector)
    %% SIGNAL NOW TRANSMITTED, Channel Attentuation and Noise addition
    % In the channel, the attentuation factor will effect both the noise and
    % the original data itself. Corrected for attenuation factor noise will be
    % added to the signal that will be received on the other side.

    %Multiply the signal by the gain factor
    gainSignal = carrierSignal*gainFactor;

    %Add AWGN based on the SNR and Attenuation Factor!
    SNR = (gainFactor^2)*SNR_vector(index);           %New SNR w/ gain factor
    receivedSignal = awgn(gainSignal, 10*log10(SNR)); %SNR must be in DB, ARE UNITS RIGHT HERE???


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
           [noisyTSequence, receivedDataSignal] = golay_sequence_detection(gainControlledSignal, training_sequence);
        case 'pn'
            % Input: (receivedSignal)
            % - receivedSignal: noisy signal passed through the channel
            % Output: (trainingSequence, receivedDataSignal
            % - training_sequence: detected PN training sequence that will be used in AGC
            % - receivedDataSignal: the rest of the signal (the data)
            [noisyTSequence, receivedDataSignal] = PNSequence_detection(receivedSignal);
        otherwise
            [noisyTSequence, receivedDataSignal] = golay_sequence_detection(training_sequence, gainControlledSignal);
    end


    %% Automatic Gain Control (Phat and Joseph)
    % Use detected training sequence to estimate the gain factor. Then divide
    % that data signal by this factor to bring it back to (hopefully) right
    % amplitude level
    
    %Correct data signal based on the gain factor using the formula Javi
    %provided us with this last week. Should be a simple mathmatical
    %calculation.
    
    %-----AGC_Known_Function------
    %Stabilizes the amplitude of a received signal given that he original is
    %known
    %Inputs:    r - the signal to be equalized
    %           knownSignal - the known original signal
    %Outputs:   estimation - gain factor estimation   
    estimatedGain = AGC_Known_Function(receivedSignal, modulatedSignal); %is modulated signal the signal expected at this point?
    
    gainControlledBits = receivedDataSignal/estimatedGain;
    
    gainErrorSquared = (gainFactor - estimatedGain)^2;
    gainError_vector(index) = gainErrorSquared;  %For plotting later

    %% Demodulate the data
    % Demodulates the data signal and assigns it to a final estimation of the
    % transmitted bits. Calculates the Bit Error Rate (Number of bit
    % errors/Total bits transmitted)

    %Use gainControlledBits and demodulate here

    %demodulatedBits = %The final estimation of the bits, TODO

    [err,BER] = biterr(demodulatedBits,sendableBits);
    ber_vector(index) = BER;  %For plotting later...
end

%% Plots (Matt)

% Plot correlation between respective training sequence and final demodulated data 
    switch training_algo
        case 'golay'
            figure(1)
            plot(abs(xcorr(demodData,trainingSequence)).^2)
            title('Golay Sequence Correlation')
        case 'pn'
            figure(1)
            plot(abs(xcorr(demodData,trainingSequence)).^2)
            title('Pseudonoise Sequence Correlation')
        otherwise
            figure(1)
            plot(abs(xcorr(demodData,trainingSequence)).^2)
            title('Golay Sequence Correlation')
    end

% TODO: Plot difference between Estimated and True gain (error squared) vs
% SNR
figure(2)
semilogy(SNR_vector, gainError_vector);
title('Gain Estimation Error')
xlabel('SNR (dB)')
ylabel('Gain Estimate Error')
%axis([-2 10 10e-5 1])

% TODO: Plot the BER vs SNR
figure(3)
semilogy(SNR_vector.', ber_vector);
title("BER vs SNR for " + modulation_type + " modulated signal using " + agc_algo + " AGC");
xlabel('SNR (dB)')
ylabel('BER')
%axis([-2 10 10e-5 1])