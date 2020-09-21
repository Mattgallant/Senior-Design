function [outSig,phaseErr] = CarrierFrequencyOffset(receivedSig)

% CARRIERFREQUENCYOFFSET Corrects the frequency of the received wave to the
% original frequency of the transmitted wave

% receivedSig should be the receieved signal that has AWGN and phase offset
% applied to it


% Carrier synchronizer System object for correcting the phase and frequency
% offsets with samples per symbol set to 1
% Change QPSK field depending on what modulation is chosen
carrierSync = comm.CarrierSynchronizer( ...
'SamplesPerSymbol',1,'Modulation','BPSK');
% Correct phase/freq offset
[outSig,phaseErr] = carrierSync(receivedSig);

end

