function transmitter_to_speaker(wave)
%TRANSMITTER_TO_SPEAKER Plays WAVE over speaker
%   Outputs WAVE at a sampling rate of 44.1kHz as a sound.   
    Fs = 44100;                    % Sampling Frequency of 44.1kHz
    sound(wave, Fs)                % Produce WAVE as sound
end

%     t  = linspace(0, 1, Fs);                % One Second Time Vector ->LINSPACE(X1, X2, N) generates N points between X1 and X2.%   For N = 1, LINSPACE returns X2.
%     w = 2*pi*9000;                          % Radian Value To Create 9kHz Tone
%     s = sin(w*t);                           % Create Sinewave
%     s_multisecond = repmat(s,1,2);          % Create a 2 second tone instead

