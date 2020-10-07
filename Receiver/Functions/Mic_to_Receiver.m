function [received_binary] = Mic_to_Receiver(seconds)
%MIC_TO_RECEIVER Records sound from laptop microphone and outbits as array
%   Takes in SECONDS as the amount of time we want to record the message
%   for. Recall the sampling rate is 44100 samples per second, so it will
%   take 1 second for every 44100 samples of data. 
%   Not too sure how to sure how to handle choosing how long to record as of now -Matt
    %% Create an audiorecorder object w/ Fs =44.1kHz, 8 bits per sample, 1 channel.
    recObj = audiorecorder(44100,8,1); % THE 8 HERE MAY BE WRONG

    %% Record Audio
    disp('Recording Started.')
    recordblocking(recObj, seconds);          %Start a recording block of 1 seconds long, holds control until done
    disp('End of Recording.');

    %% Convert to data array
    y = getaudiodata(recObj);           %Double as default
    x = getaudiodata(recObj, 'uint8');
    b = de2bi(x);                       %Convert to binary
    received_binary = reshape(b,1,[]);

    %% Plot and play the sound data
    %play(recObj);                       %Play the recorded audio
%     figure(1)
%     plot(y);                            %Plot the double data
% 
%     figure(2);
%     plot(x);
% 
%     figure(3);                          %Plot the binary data
%     plot(b);
%     axis([0 500 0 1.05])
%     title("Binary Values");
% 
%     disp(b)
end

