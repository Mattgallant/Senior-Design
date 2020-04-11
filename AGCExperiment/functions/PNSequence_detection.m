function [training_sequence, data] = PNSequence_detection(receivedSignal)
% Separate the receivedSignal by separating the training sequence from the
% rest of the data

training_sequence = receivedSignal(1,32);
data = receivedSignal(33,end);