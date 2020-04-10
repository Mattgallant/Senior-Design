%AGC_golay_sequence_generation
% Generate Golay sequence
% Embed sequence within input signal
% Use Ga as the sequence and embed in the input_modulation.m before
% modulation occurs
function[data_in, training_sequence]= golay_sequence_generation(sendableBits, loc)
    [Ga,Gb] = wlanGolaySequence(32);
    training_sequence = reshape(Ga, [1,32]);
    for bit = 1: length(training_sequence)
        if training_sequence(bit)== -1
            training_sequence(bit) = 0;
        end
    end
    data_in = [sendableBits(1:loc) num2str(training_sequence) sendableBits(loc+1:end)];
