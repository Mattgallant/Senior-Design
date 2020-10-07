function [output_bits] = turbo_encoding(input_bits)
%TURBO_ENCODING Turbo encodes input data and returns the coded data
%   Uses the LTE Comm library and takes INPUT_BITS, turbo encodes it and returns
%   the encoded bitstream. Coding rate is ~ 1/5. INPUT_BITS must be a column vector!
    trellis = poly2trellis(4,[13 15 17],13);
    rng default;
    interleaver_indicies = randperm(length(input_bits));
    
    turboEncoder = comm.TurboEncoder(trellis, interleaver_indicies);
    output_bits = turboEncoder(input_bits);
%     disp("Coding rate is approximately: " + rat(length(input_bits)/length(output_bits), .001));
end

