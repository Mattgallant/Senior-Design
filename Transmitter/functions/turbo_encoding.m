function [output_bits] = turbo_encoding(input_bits)
%TURBO_ENCODING Turbo encodes input data and returns the coded data
%   Uses the LTE Comm library and takes INPUT_BITS, turbo encodes it and returns
%   the encoded bitstream. Coding rate is ~ 1/3. INPUT_BITS must be a column vector!
    rng default
    turboEncoder = comm.TurboEncoder('InterleaverIndicesSource','Input port');
    output_bits = step(turboEncoder, input_bits, randperm(length(input_bits)));
    %disp("Coding rate is approximately: " + rat(length(input_bits)/length(output_bits), .001));
end

