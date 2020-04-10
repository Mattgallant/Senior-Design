function [sourceCharacters,sendableBits] = Input(numberOfBits)
    %Open source file
    filePointer= fopen('alice_in_wonderland.txt');
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
    sendableBits= reshapedBinaryValuesArray(1:numberOfBits);
    %disp(sendableBits);