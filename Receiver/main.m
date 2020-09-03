% main script for the receiver. All receiver functions should be
% plugged into this file.

%% Input from microphone (Matt)
% Mic_to_Receiver(Seconds to record)
    binary_input = Mic_to_Receiver(5); % Record for 5 seconds
    disp(binary_input)