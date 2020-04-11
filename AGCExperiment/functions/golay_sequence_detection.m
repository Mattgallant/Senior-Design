% AGC_golay_sequence_detection
% Detect Ga sequence within reveived signal

function[training_sequence, retrieved_sequence]= golay_sequence_detection(data, training_sequence)
    retrieved_sequence = data(1:32);
    
    y=xcorr(training_sequence, data);                 % do cross correlation
    [m,ind]=max(y);                        % location of largest correlation
    
    % subplot(4,1,1), stem(training_sequence)           % plot training sequence
    % title('Training Sequence')
    % subplot(4,1,2), stem(data)             % plot data sequence
    % title('Data With Embedded Trainging Sequence')
    % subplot(4,1,3), stem(y)                % plot correlation
    % title('Correlation of Training Sequence With Data')
    % subplot(4,1,4),plot(abs(xcorr(data,training_sequence).^2))
    % title('Correlation of Training Sequence With Data')