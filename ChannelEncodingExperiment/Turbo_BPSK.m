% Carolyns's part of the channel encoding risk reduction experiment. This is not currently done.
% trubo channel encoding using an AWGN channel and BPSK 
% Source: https://www.mathworks.com/help/lte/ref/lteturbodecode.html

% generate random bit stream
inputStream = randi([0 1],6144,1);
disp(num2str(inputStream(:).'));
% turbo encode bitstream
codedData = lteTurboEncode(inputStream);
% modulate the encoded bits with BPSK
txSymbols = lteSymbolModulate(codedData,'BPSK');
disp(num2str(txSymbols(:).'));
% generate noise
noise = 0.5*complex(randn(size(txSymbols)),randn(size(txSymbols)));
% add noise to the signal
rxSymbols = txSymbols + noise;

% demodulate teh signal
softBits = lteSymbolDemodulate(rxSymbols,'BPSK','Soft');
% decode the signal
outputStream = lteTurboDecode(softBits);
disp(num2str(outputStream(:).'));

% calculate and display errors
numberErrors = sum(outputStream ~= int8(inputStream));
string = ['Number of errors: ', num2str(numberErrors)];
disp(string)