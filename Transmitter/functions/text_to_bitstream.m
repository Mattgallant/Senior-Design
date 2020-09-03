
%TEXT_TO_BITSTREAM Function that converts a text document to a bitstream
%   Function takes in a value that represents the number of bits to be sent
%   and the text file and converts it to bits until the specified amount is reached

function [sourceCharacters,sendableBits] = text_to_bitstream(filePointer,numberOfBits)
    %Read in characters of book
    fileValues= fscanf(filePointer,'%c');
    %Convert character values to binary
    binaryValues = dec2bin(fileValues);
    %CharactersBeingTested divided by 8 because of size of character is 8bit
    sourceCharacters= fileValues(1:fix(numberOfBits/8)); %in ascii
    %disp(sourceCharacters);
    %Get the number of Rows and Columns of Binary Data
    [rows,columns] = size(binaryValues);
    %Reshapes to one row, and necessary number of Columns
    reshapedBinaryValuesArray= reshape(binaryValues', 1, rows*columns);
    %Creates the array for the number of bits to send 
    characterConversion= reshapedBinaryValuesArray(1:numberOfBits);
    sendableBits= zeros(1,numberOfBits);    
    zeroValue='0';
    oneValue='1';
    %Converts from character binary values to actual double binary values
    %Enables better use of modulation and other number based libraries
    for i=1:1:numberOfBits
        if(strcmp(characterConversion(i),oneValue))
            sendableBits(i)=1;
        elseif(strcmp(characterConversion(i),zeroValue))
            sendableBits(i)=0;
        end        
    end
end