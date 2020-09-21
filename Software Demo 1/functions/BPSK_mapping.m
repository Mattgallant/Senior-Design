function [modulated_bits] = BPSK_mapping(input_bits)
%BPSK_ MAPPING BPSK modulates the input bits
%   Takes INPUT_BITS and uses BPSK to modulate them. 
    %Grab input paramenter information
    %[~,numberOfEntries] = size(input_bits);
    BPSKModulator= comm.BPSKModulator;
    %convert to vertical column vector  so BPSK can take in 
    BPSKSignalVector = BPSKModulator(input_bits(:));
    modulated_bits= BPSKSignalVector.';
end

