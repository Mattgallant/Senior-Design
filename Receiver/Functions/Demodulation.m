%-----Demodulation------
%Demodulates a BPSK signal into bits
%Inputs:    inputSignal - the BPSK signal
%Outputs:   demodulatedSignal - the demodulated signal
function[demodulatedSignal] = Demodulation(inputSignal)
    %ModulationOrder=1;
    BPSKDemodulator= comm.BPSKDemodulator;
    demodulatedSignal = BPSKDemodulator(inputSignal(:));
    %[rows,numberOfEntries] = size(demodulatedSignal);
    demodulatedSignal= demodulatedSignal.';
end

        
    
    

   
    
    
    




