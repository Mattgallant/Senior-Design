%Matt's individual risk reduction experiment. Microphone Input Part
%Still work in progress....

%% Create an audiorecorder object w/ default parameters.
recObj = audiorecorder; 

%% Record Audio
disp('Start Speaking.')
recordblocking(recObj, 1);          %Start a recording block of 5 seconds long
disp('End of Recording.');

%% Convert to data array
y = getaudiodata(recObj);           %Double as default
x = getaudiodata(recObj, 'uint8');
b = de2bi(x);                        %Convert to binary
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

