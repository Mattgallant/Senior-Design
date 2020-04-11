% AGC_golay_sequence_detection
% Detect Ga sequence within reveived signal

function[retrieved_sequence, retrieved_data]= golay_sequence_detection(data)

    retrieved_sequence = data(1:32);
    retrieved_data = data(33:end);
 
    %y=xcorr(training_sequence, data);      % do cross correlation
   % [m,ind]=max(y);                        % location of largest correlation
  %  headstart=length(data)-ind+1;          % place where training sequence starts
    
   % retrieved_sequence = data(headstart : headstart+32);
    %retrieved_data = data(headstart+33 : end);
    
        