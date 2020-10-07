
%BITSTREAM_TO_TEXT Function that converts a bitstream to a text document
%   Function takes in the bitstream
%   and converts it to a text file

function [textValues] = Bitstream_to_Text(bitstream)
    disp(size(bitstream))
    reshapedArray = reshape(bitstream(:), 7, []).';  
    disp(size(reshapedArray))
    binaryCharArray= num2str(reshapedArray);
    disp(size(binaryCharArray))
    decimalAsciiValues = bin2dec(binaryCharArray);
    textValues= char(decimalAsciiValues).';
end