function [downconverted_wave] = downconvert(wave)
%DOWNCONVERT Takes WAVE and downconverts it from the center frequency
%   Takes SRRC filtered digital signal (WAVE) and multiplies it by an
%   appropriate carrier wave. The downconverted wave should be a cos wave
%   and have center frequency of 9kHz. Returns the DOWNCONVERTED_WAVE.
    center_frequency = 9000;    % As per project definition, center freq 9kHz
    Fs = 44100;                 % Sampling Frequency of 44.1kHz (Samples per Second)
    dt = 1/Fs;                  % Seconds per sample
    
    % Create the carrier wave
    t = (0:dt:(length(wave) - 1)/Fs);   % Create time vector for transmition. Recall want 44.1k "samples" per second.
    w = 2*pi*center_frequency;      % Radian value to create 9kHz
    carrier = cos(w*t);             % Create carrier sinewave
    
    % Remove carrier wave
    downconverted_wave = 2 *( wave.* carrier);
   
%     figure;
%     plottf(downconverted_wave,1/Fs);
%     title("Downconverted Data w/o LPF")
    
    %LPF ---!!!!!!!!!!!!!!!! currently causing bit error ???
    % We may not need this since SRRC acts as the LPF?
    x = load('please.mat');      %done with filter design/fdatool
downconverted_wave = filter(x.FilterTest, 1, downconverted_wave);                % calculation of LPF impulse response
%% DEBUG  
%     figure;
%     plot(t,wave.*carrier);
%     xlabel('time (in seconds)');
%     title('Downconverted Wave w/ Data');
%     zoom xon;
end

