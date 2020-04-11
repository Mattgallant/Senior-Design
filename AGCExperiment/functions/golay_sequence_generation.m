% AGC_golay_sequence_generation
% Generate Golay sequence Embed Ga sequence at beginning of modulated signal

function[data_in, training_sequence]= golay_sequence_generation(modulatedSignal)
    [Ga,Gb] = wlanGolaySequence(32);
    training_sequence = reshape(Ga, [1,32]);
    %for bit = 1: length(training_sequence)
       % if training_sequence(bit)== -1
      %      training_sequence(bit) = 0;
     %   end
    %end
    data_in = [training_sequence modulatedSignal];
