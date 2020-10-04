%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%

function [y,err] = ChannelEqualization(recieved_signal,trainingSymbols)
    % May need to make the training symbols complex in order to concatonate
    % them with the recieved signal
    trainingSymbols = complex(trainingSymbols');
    
    %Initialize the Equalizer object, to tune it, change the taps integers
    dfeq = comm.DecisionFeedbackEqualizer('Algorithm','LMS',...
        'NumForwardTaps',5,'NumFeedbackTaps',4,...
        'Constellation',bpsk((0:1)'),'ReferenceTap',3,'StepSize',0.01);
    
    % Determines how many times you want to tune the equalizer
    numPkts = 10;
    for ii = 1:numPkts
        % Concatonate the training symbols with the received signal
        packet = [trainingSymbols;recieved_signal];
        % Attempt to equalize by passing the concatoned signal and the
        % training symbols to the DecisionFeedbackEqualizer object
        [y_train,err_train] = dfeq(packet,trainingSymbols);
    end
    % y is the equalized signal, err is the error in the signal
    [y,err] = dfeq(rx,trainingSymbols);
end

