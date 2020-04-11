% AGC_golay_sequence_detection
% Detect Ga sequence within reveived signal

function[retrieved_sequence, retrieved_data]= golay_sequence_detection(data)

    retrieved_sequence = data(1:32);
    retrieved_data = data(33:end);
 