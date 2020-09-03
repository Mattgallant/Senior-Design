function [output_bits] = turbo_encoding(input_bits)
%TURBO_ENCODING Turbo encodes input data and returns the coded data
%   Uses the LTE library and takes INPUT_BITS, turbo encodes it and returns
%   the encoded bitstream. As of now, turbo encode seems to produce ~ 2
%   bits for every 1 bit of input. INPUT_BITS must be a multiple of 8!
    output_bits = lteTurboEncode(input_bits);
end

