function [downconverted_wave] = downconvert(wave)
%DOWNCONVERT Takes WAVE and downconverts it from the center frequency
%   Takes SRRC filtered digital signal (WAVE) and multiplies it by an
%   appropriate carrier wave. The downconverted wave should be a cos wave
%   and have center frequency of 9kHz. Returns the DOWNCONVERTED_WAVE.
    fc = 9000;    % As per project definition, center freq 9kHz
    Fs = 44100;                 % Sampling Frequency of 44.1kHz (Samples per Second)
    dt = 1/Fs;                  % Seconds per sample
    
    % Create the carrier wave
    M = 6; %sps
    %t=1/M:1/M:length(wave)/M;              % T/M-spaced time vector
    t = (0:dt:(length(wave) - 1)/Fs);   % Create time vector for transmition. Recall want 44.1k "samples" per second.
    w = 2*pi*fc;      % Radian value to create 9kHz
    carrier = cos(w*t);             % Create carrier sinewave
    %peak to peak is x=1 to x=6

    % Remove carrier wave
    downconverted_wave = 2 .*( wave .* carrier);
   
    Lh = 201;                        % Impulse response length
    Fpb = 2400;                     % Passband Edge in Hz
    Fsb = 2900;                     % Stopband edge in Hz
    Fs = 44100;

    h = firlpf(Lh, Fpb, Fsb ,Fs);
    downconverted_wave = filter(h, 1, downconverted_wave);
    
    %LPF
%     x = load('LPF.mat');      %done with filter design/fdatool
%     delay = ceil((length(x.Num)-1)/2);   
%     filtered = filter(x.Num, 1, downconverted_wave);                % calculation of LPF impulse response
%     downconverted_wave = [filtered(delay : end) zeros(1, delay)];
%% DEBUG  
%     figure;
%     plotspec(real(downconverted_wave), 1/44100);
%     title('Downconverted Wave w/ Data');
end

