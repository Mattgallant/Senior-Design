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
    t=1/M:1/M:length(wave)/M;              % T/M-spaced time vector
    %t = (0:dt:(length(wave) - 1)/Fs);   % Create time vector for transmition. Recall want 44.1k "samples" per second.
    w = 2*pi*fc;      % Radian value to create 9kHz
    carrier = cos(w*t);             % Create carrier sinewave
    
    % Remove carrier wave
    downconverted_wave = 2 .*( wave.* carrier);
   
%     figure;
%     plotspec(downconverted_wave,1/Fs);
%     title("Downconverted Data w/o LPF")
    
    %LPF --- working
    x = load('please.mat');      %done with filter design/fdatool
    
%     figure;
%     plottf(x.FilterTest,1/Fs);
%     title("Pulse Shaped")
    
    
    filtered = filter(x.FilterTest, 1, downconverted_wave);                % calculation of LPF impulse response
    delay = ceil((length(x.FilterTest)-1)/2);                               %needs to be integer
    downconverted_wave = [filtered(delay:end) zeros(1,delay)];             %padded 0s at the end to keep size for now
%% DEBUG  
%     figure;
%     plot(t,wave.*carrier);
%     xlabel('time (in seconds)');
%     title('Downconverted Wave w/ Data');
%     zoom xon;
end

