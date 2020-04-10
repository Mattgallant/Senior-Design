function PNSequence_detection(data, training_sequence)

% Create Pseudonumber sequence object with certain properties
%pnSequence = comm.PNSequence('Polynomial',[3 2 0],'SamplesPerFrame',7,'InitialConditions',[0 0 1]);

% Generate the PN training sequence
%training_sequence = pnSequence();
%training_sequence = training_sequence';

% Generate random received signal with embedded sequence
% loc=30; r=25;
% data=[sign(randn(1,loc-1)) training_sequence sign(randn(1,r))];  % generate random signal
% sd=.25; data=data+sd*randn(size(data));              % add noise

% Detect sequence and plot
plot(abs(xcorr(data,training_sequence)).^2);