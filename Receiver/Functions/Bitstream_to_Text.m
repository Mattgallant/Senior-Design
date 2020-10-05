
%BITSTREAM_TO_TEXT Function that converts a bitstream to a text document
%   Function takes in the bitstream
%   and converts it to a text file

function [textValues] = Bitstream_to_Text(bitstream)
    reshapedArray = reshape(bitstream(:), 7, []).';  
    binaryCharArray= num2str(reshapedArray);
    decimalAsciiValues = bin2dec(binaryCharArray);
    textValues= char(decimalAsciiValues).';
end