% Read The Input File
filename = "Quijote.txt";
inputFile = fopen(filename,'r');
fprintf("\nOpened file: %s\n",filename);
formatSpec = '%c';
size_inputChars = [1 Inf];
inputChars = fscanf(inputFile,formatSpec,size_inputChars);
fclose(input_file);
fprintf("\nSize of array inputChars: %d", size(inputChars));

% Get a bitstream array from the inputChars array 1st 5 chars
bitstream = [];
for n = 1:5%length(inputChars)
    dec = dec2bin(inputChars(1,n));
    bin_array = logical(dec-'0');
    bitstream = horzcat(bitstream,bin_array); %Use a preallocation method to make faster
end
fprintf("\n");
fprintf("%d",bitstream);