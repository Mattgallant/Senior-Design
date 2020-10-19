%example provided in https://www.mathworks.com/help/comm/ref/comm.decisionfeedbackequalizer-system-object.html
%System setup
M = 2;
numTrainSymbols = 128;
numDataSymbols = 1800;
SNR = 20;
%trainingSymbols = pskmod(randi([0 M-1],numTrainSymbols,1),M,pi/4);
bpsk = comm.BPSKModulator;
%Using Golay
[Ga,~] = wlanGolaySequence(numTrainSymbols);
trainingSymbols = reshape(Ga, [1,numTrainSymbols]);
%following line added to work with rest of example script, dimensions
%flipped, I think I changed script from QPSK to BPSK
trainingSymbols = complex(trainingSymbols'); %!!!issues with elements not being complex valued
%end of golay
numPkts = 10;
dfeq = comm.DecisionFeedbackEqualizer('Algorithm','LMS', ...
    'NumForwardTaps',5,'NumFeedbackTaps',4,'Constellation',bpsk((0:1)'),'ReferenceTap',3,'StepSize',0.01);

%train equalizer w/o reset
release(dfeq)
jj = 1;
figure
c             % define channel
for ii = 1:numPkts
    b = randi([0 M-1],numDataSymbols,1);
    dataSym = bpsk(b);                          %changed from qpsk to bpsk
    packet = [trainingSymbols;dataSym];
    channel = 1;
    rx = filter(chCo,1,packet);             %awgn(packet*channel,SNR); %channel simulation line
    [y,err] = dfeq(rx,trainingSymbols);
    if (ii ==1 || ii == 2 ||ii == numPkts)      %BER worse than QPSK, acts like being reset every packet
        %subplot(3,1,jj)
        %plot(abs(err))
        
        scatter(complex([1:length(y)])', y)
        %scatter(complex([1:length(dataSym)])', dataSym)
        %scatter(complex([1:length(rx)])', rx)
        %ylim([0 1])
        ylim([-1 1])
        title(['Packet # ',num2str(ii)])
        xlabel('Symbols');
        ylabel('Error Magnitude');
        grid on;
        jj = jj+1;
    end
end