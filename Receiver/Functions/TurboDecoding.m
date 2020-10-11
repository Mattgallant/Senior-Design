%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%
%should be found in encoding risk reduction

function output_bits = TurboDecoding(input_bits)
%TURBODECODING Turbo decoeds INPUT_BITS and returns the result OUTPUT_BITS
%   Currently configured a coding rate of 1/5
%     disp("Turbo Decode input length: " + length(input_bits))
    trellis = poly2trellis(4,[13 15 17],13);
    rng default;
    original_length = (length(input_bits) - 18)/5;      % Used to calculate interleaver indicies
    interleaver_indicies = randperm(original_length);
    
    turbodec = comm.TurboDecoder(trellis,interleaver_indicies ,4);
    output_bits = turbodec(input_bits);
%     disp("Turbo Decode output length: " + length(output_bits))
end

