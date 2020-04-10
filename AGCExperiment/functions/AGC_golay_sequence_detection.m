% AGC_golay_sequence_detection
bit = bit*2+1
% Generate Golay sequence
% Embed sequence within input signal
% Use Ga as the sequence and embed in the input_modulation.m before
% modulation occurs
[Ga,Gb] = wlanGolaySequence(32);
loc =50;
r = 100;
signal = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
header = reshape(Ga, [1,32]);
disp(header)
for bit = 1: length(header)
    if header(bit)== -1
        header(bit) = 0;
    end
end
disp(header)
%data=[sign(randn(1,loc-1)) header sign(randn(1,r))];
data = [signal(1:10) header signal(10:end)]
% Pass signal through channel to the reciever
% COMPLETED by other functions

% Detect Ga sequence within reveived signal
y=xcorr(header, data);                 % do cross correlation
[m,ind]=max(y);                        % location of largest correlation
headstart=length(data)-ind+1;          % place where header starts
if ( loc == headstart )
    totalCorrect = totalCorrect + 1;
end

totalCorrect / totalRuns;
subplot(4,1,1), stem(header)           % plot header
title('Header')
subplot(4,1,2), stem(data)             % plot data sequence
title('Data with embedded header')
subplot(4,1,3), stem(y)                % plot correlation
title('Correlation of header with data')
subplot(4,1,4),plot(abs(xcorr(data,header).^2))
title('Javis Plot')
