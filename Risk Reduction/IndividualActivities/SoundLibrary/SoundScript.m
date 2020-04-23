%Matt's individual risk reduction experiment. Microphone Input Part
% https://www.mathworks.com/help/matlab/audio-and-video.html?category=audio-and-video&s_tid=CRUX_gn_documentation_audio-and-video

%% Create an audiorecorder object w/ default parameters.
recObj = audiorecorder; 

%% Record Audio
disp('Start Speaking.')
recordblocking(recObj, 3);          %Start a recording block of 1 seconds long, holds control until done
disp('End of Recording.');

%% Convert to data array
y = getaudiodata(recObj);           %Double as default
x = getaudiodata(recObj, 'uint8');
b = de2bi(x);                       %Convert to binary
b = reshape(b,1,[]);

%% Plot and play the sound data
play(recObj);                       %Play the recorded audio

figure(1)
plot(y);                            %Plot the double data

figure(2);
plot(x);

figure(3);                          %Plot the binary data
plot(b);
axis([0 500 0 1.05])
title("Binary Values");

disp(b)

%% Outputting a sine wave as sound with freq of 9kHz and Sampling 44.1kHz
Fs = 44100;                             % Sampling Frequency of 44.1kHz
t  = linspace(0, 1, Fs);                % One Second Time Vector ->LINSPACE(X1, X2, N) generates N points between X1 and X2.%   For N = 1, LINSPACE returns X2.
w = 2*pi*9000;                          % Radian Value To Create 9kHz Tone
s = sin(w*t);                           % Create Sinewave
s_multisecond = repmat(s,1,2);          % Create a 2 second tone instead
sound(s_multisecond, Fs)                % Produce Tone As Sound, sample rate Fs must be >= 2*Tone Frequency to play accurately 

