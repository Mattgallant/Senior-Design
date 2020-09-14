function [upconverted_wave] = upconvert(wave)
%UPCONVERT Takes WAVE and upconverts it to desired carrier frequency
%   Takes SRRC filtered digital signal (WAVE) and multiplies it by an
%   appropriate carrier wave. The upconverted wave should be a sine wave
%   and have center frequency of 9kHz. Returns the UPCONVERTED_WAVE.
    center_frequency = 9000;    % As per project definition, center freq 9kHz
    Fs = 44100;                 % Sampling Frequency of 44.1kHz (Samples per Second)
    dt = 1/Fs;                  % Seconds per sample
    
    % Create the carrier wave
    t = (0:dt:(length(wave) - 1)/Fs);   % Create time vector for transmition. Recall want 44.1k "samples" per second.
    w = 2*pi*center_frequency;      % Radian value to create 9kHz
    carrier = sin(w*t);             % Create carrier sinewave
    
    figure(1);
    plot(t,carrier);
    xlabel('time (in seconds)');
    title('Carrier Wave');
    zoom xon;
    
    figure(2);
    plot(t,wave.*carrier);
    xlabel('time (in seconds)');
    title('Carrier Wave Modulated w/ Data');
    zoom xon;
    upconverted_wave = wave.* carrier;
end

