%AGC_golay_sequence_generation
% Generate Golay sequence
% Embed sequence within input signal
% Use Ga as the sequence and embed in the input_modulation.m before
% modulation occurs
function[data_in]= golay_sequence_generation(sendableBits, loc)
    [Ga,Gb] = wlanGolaySequence(32);
    training_sequence = reshape(Ga, [1,32]);
    data_in = [sendableBits(1:loc) training_sequence sendableBits(loc+1:end)];
