%Set the filename
filename = "Quijote.txt";
%Open the file: filename, for reading
input_file = fopen(filename,'r');
%Set the read format for the file - %c: char
format_spec = '%c';
%Set the amount of chars in the file to read
read_length = 5;
%Read the file as a cell array of whatever formatSpec defines
text = textscan(input_file,format_spec,read_length);
%Close the input_file
fclose(input_file);
%Print the text array (optional)
celldisp(text);
%Convert the chars into their ASCII numbers
ascii_text = double(char(text));
%Print the ascii_text array (optional)
fprintf("%d, ",ascii_text);
%Convert ascii_text array into unsigned int8 array representing bits
%Adapted from Walter Robinson = https://www.mathworks.com/matlabcentral/answers/305999-how-to-convert-a-string-to-binary-and-then-from-the-binary-back-to-string
binary_text = reshape(dec2bin(ascii_text,8).'-'0',1,[]);
%Print binary_text (optional)
fprintf("\n\n");
fprintf("%d, ",binary_text);