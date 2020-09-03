function [bits] = string_to_bitstream(input)
%STRING_TO_BITSTREAM Converts INPUT (a string) to binary
%   Detailed explanation goes here

    %Convert character values to binary
    binaryValues = dec2bin(input);

    %Get the number of Rows and Columns of Binary Data
    [rows,columns] = size(binaryValues);
    %Reshapes to one row, and necessary number of Columns
    reshapedBinaryValuesArray= reshape(binaryValues', 1, rows*columns);
    %Creates the array for the number of bits to send 
    characterConversion= reshapedBinaryValuesArray(1:numberOfBits);
    bits= zeros(1,numberOfBits);    
    zeroValue='0';
    oneValue='1';
    %Converts from character binary values to actual double binary values
    %Enables better use of modulation and other number based libraries
    for i=1:1:numberOfBits
        if(strcmp(characterConversion(i),oneValue))
            bits(i)=1;
        elseif(strcmp(characterConversion(i),zeroValue))
            bits(i)=0;
        end        
    end
end

