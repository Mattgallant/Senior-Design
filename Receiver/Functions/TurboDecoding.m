%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%
%should be found in encoding risk reduction

function output_bits = TurboDecoding(input_bits)
%TURBODECODING Turbo decoeds INPUT_BITS and returns the result OUTPUT_BITS
%   Currently configured a coding rate of 1/5
    trellis = poly2trellis(4,[13 15 17],13);
    rng default;
    
    % Very jank solution. Addresses possible delay and bit length mistmach.
    %%%%%
%     needed_bits = 5-mod((length(input_bits) - 18), 5);
%     zero_array = zeros(1, needed_bits);
%     input_bits = [input_bits zero_array];
    %%%%%
    
    
    original_length = (length(input_bits) - 18)/5;      % Used to calculate interleaver indicies
    interleaver_indicies = randperm(original_length);
    
    turbodec = comm.TurboDecoder(trellis,interleaver_indicies ,4);
    output_bits = turbodec(input_bits.');
end

