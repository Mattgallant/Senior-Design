%% Channel Equalization Testing
% Matt's place for messing around with channel equalization library
% https://www.mathworks.com/help/comm/equalization.html?category=equalization&s_tid=CRUX_topnav

errorRate = comm.ErrorRate;

%% Test LMS Equalizer
data = randi([0 1],1000,1);
modData = pskmod(data,2);

rxSig = conv(modData,[0.5 0.05]);

alg = lms(0.06);

eqlms = lineareq(8,alg);
eqlms.RefTap = 4;

trSeq = data(1:200);
for n= 1:50
    [rxSig,~,e] = equalize(eqlms,rxSig,trSeq);
end

disp(rxSig)
constDiagram = comm.ConstellationDiagram('NumInputPorts', 1, 'ReferenceConstellation',pskmod(0:1,2));
constDiagram(rxSig)
%% Test MLSE Equalizer

% chCoeffs = [.986+ .2i];
% 
% % Create MLSE equalizer object
% % mlse = comm.MLSEEqualizer('TracebackDepth',10,...
% %     'Channel',chCoeffs,'Constellation',pskmod(0:1,2));
% mlse = comm.MLSEEqualizer('TracebackDepth',10, 'Constellation',pskmod(0:1,2));
% 
% for n = 1:500
%     data= randi([0 1],10000,1);
%     modSignal = pskmod(data,2, 0, 'gray');
% 
%     % Introduce channel distortion.
%     % chanOutput = filter(chCoeffs,1,modSignal);
%     chanOutput = filter(chCoeffs,1,modSignal); 
% 
%     % Equalize the channel output and demodulate.
%     eqSignal = mlse(chanOutput);
%     demodData = pskdemod(eqSignal,2, 0, 'gray');
%     
%     errorStats = errorRate(data,demodData);
%     ber = errorStats(1)
%     numErrors = errorStats(2)
% end
% constDiagram = comm.ConstellationDiagram('NumInputPorts', 1, 'ReferenceConstellation',pskmod(0:1,2));
% constDiagram(eqSignal)

%% Test Linear Equalizer
% Create BPSK and Equalizer Objects
% bpsk = comm.BPSKModulator;
% eqlms = comm.LinearEqualizer('Algorithm','LMS','NumTaps',8,'StepSize',0.03);
% 
% eqlms.ReferenceTap = 4;
% 
% data = randi([0 1], 1000, 1);
% x = bpsk(data);
% 
% rxsig = conv(x, [1 0.8 0.3]);   % Introduce some channel distortion
% % disp(rxsig)
% 
% mxStep = maxstep(eqlms, rxsig)
% 
% y = eqlms(rxsig,x(1:200));
% disp(y)
% 
% constell = comm.ConstellationDiagram('NumInputPorts',2);
% constell(y, rxsig)