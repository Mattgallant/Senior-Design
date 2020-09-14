% Script to demonstrate that Upconversion is correctly outputting a carrier
% wave at the correct frequency without any modulated data added.
    wave = randi([0, 1], 30000, 1);

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
    
    % Play wave
    Fs = 44100;                    % Sampling Frequency of 44.1kHz
    disp("SOUND PLAYING");
    sound(carrier, Fs)                % Produce WAVE as sound
    