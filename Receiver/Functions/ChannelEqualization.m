%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%

function [y,err] = ChannelEqualization(recieved_signal, received_sequence, trainingSymbols)
    
    %Initialize the Equalizer object, to tune it, change the taps integers      
    dfeq = comm.DecisionFeedbackEqualizer('Algorithm','LMS',...
        'NumForwardTaps',5,'NumFeedbackTaps',4,...
        'Constellation',pskmod((0:1)',2,0),'ReferenceTap',3,'StepSize',0.01);
    
    trainingSymbols = complex(trainingSymbols');
    packet = [received_sequence;recieved_signal];
    packet = packet(:);
    
    % Determines how many times you want to tune the equalizer
    numPkts = 1;
    for ii = 1:numPkts
        % Attempt to equalize by passing the concatoned signal and the
        % training symbols to the DecisionFeedbackEqualizer object
        [y_train,err_train] = dfeq(packet,trainingSymbols);
    end
    % y is the equalized signal, err is the error in the signal
    [y,err] = dfeq(packet,trainingSymbols);
end

