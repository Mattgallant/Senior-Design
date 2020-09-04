function [data_in, training_sequence] = golay_injection(modulatedSignal, sequence_length)
    [Ga,~] = wlanGolaySequence(sequence_length);
    training_sequence = reshape(Ga, [1,sequence_length]);
    data_in = [training_sequence modulatedSignal];
end

