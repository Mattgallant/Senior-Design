% AGC_golay_sequence_detection
% Detect Ga sequence within reveived signal

function[retrieved_sequence, retrieved_data]= golay_sequence_detection(data,sequence_length)

    retrieved_sequence = real(data(1:sequence_length));
    retrieved_data = data(sequence_length+1:end);
 
    %y=xcorr(training_sequence, data);      % do cross correlation
   % [m,ind]=max(y);                        % location of largest correlation
  %  headstart=length(data)-ind+1;          % place where training sequence starts
    
   % retrieved_sequence = data(headstart : headstart+32);
    %retrieved_data = data(headstart+33 : end);
    
        