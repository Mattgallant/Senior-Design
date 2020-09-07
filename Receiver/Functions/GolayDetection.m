%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%
%in risk reduction

function [retrieved_sequence, retrieved_data] = GolayDetection(data,sequence_length, training_sequence)
%GOLAYDETECTION Summary of this function goes here
%Detailed explanation goes here
    %Option 1: This was used in the risk reduction. We pulled the bits from
    %the exact same original location that they were placed
    %retrieved_sequence = real(data(1:sequence_length));
    %retrieved_data = data(sequence_length+1:end);

    %Option 2: This used correlation to determine where the start of the
    %training sequence begins and pulls it from the determined position
    y=xcorr(training_sequence, data);      % do cross correlation
    [m,ind]=max(y);                        % location of largest correlation
    headstart=length(data)-ind+1;          % place where training sequence starts

    retrieved_sequence = data(headstart : headstart+32);
    retrieved_data = data(headstart+33 : end);

end

