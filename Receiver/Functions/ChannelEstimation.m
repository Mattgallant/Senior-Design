function [rx_equalized, err] = ChannelEstimation(gainCorrectedSequence, gainCorrectedSignal, originalTrainingSequence)

    %Combine Gain Corrected Sequence And Signal for Channel Estimation
    gainCorrectedPacket=[gainCorrectedSequence,gainCorrectedSignal];
    %Turn original Training Sequence into Complex Values to train Equalizer
    complexTrainingSequence= complex(originalTrainingSequence);
    
    bpsk = comm.BPSKModulator;
    eq = comm.LinearEqualizer('Algorithm','LMS','ReferenceTap',1,'StepSize',0.001, 'Constellation',bpsk((0:1)'));
    % Estimate the channel and equalize with each step, each packet you pass
    % will train the equalizer object and update its weights
    numPkts = 25;
    
    for ii = 1:numPkts
        [rx_equalized, err] = eq(complex(gainCorrectedPacket).' , complexTrainingSequence.');
    end
    [rx_equalized, err] = eq(gainCorrectedPacket.' , complexTrainingSequence.');
    % isolate the data from the training sequence
    rx_equalized = rx_equalized(length(complexTrainingSequence) + 1 : end);
end