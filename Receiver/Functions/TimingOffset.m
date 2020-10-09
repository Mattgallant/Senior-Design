%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%

function [correctedSignal] = TimingOffset(signal, sps)
%TIMINGOFFSET - corrects the symbol timing of a signal without being aided
%by known data
%   input: signal - signal to be corrected for symbol timing
%          sps - samples per symbol (oversampling factor)
%   output: correctedSignal - the signal with corrected timing offset
symbolSync = comm.SymbolSynchronizer(...
    'SamplesPerSymbol',sps, ...
    'NormalizedLoopBandwidth',0.01, ...
    'DampingFactor',1.0, ...                %these 2 values can be tuned to improve offset
    'TimingErrorDetector','Early-Late (non-data-aided)');   %early-late vs gardner 

[correctedSignal,~] = symbolSync(signal); %Note: ~ is err
end

