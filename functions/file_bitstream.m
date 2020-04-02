%Reads in a local file with filename, and outputs a bitstream array
%If read_length arguement is not given, defaults to value 0
function bitstream = file_bitstream(filename,read_length)
    %Open the file: filename, for reading
    input_file = fopen(filename,'r');
    %Set the read format for the file - %c: char
    format_spec = '%c';
    text = "error";
    %if read length arguement is not passed in read_length defaults to 0
    if nargin == 2
        read_length = 0;
    end
    %if read_length == 0, read the whole file, if not, read up to # of chars
    if read_length == 0
        text = textscan(input,format_spec);
    end
    if read_length > 0
        %Read the file as a cell array of whatever formatSpec defines
        text = textscan(input_file,format_spec,read_length);   
    end

    %Close the input_file
    fclose(input_file);
    %Print the text array (optional)
    celldisp(text);
    %Convert the chars into their ASCII numbers
    ascii_text = double(char(text));
    %Print the ascii_text array (optional)
    %fprintf("%d, ",ascii_text);
    %Convert ascii_text array into unsigned int8 array representing bits
    %Adapted from Walter Robinson = https://www.mathworks.com/matlabcentral/answers/305999-how-to-convert-a-string-to-binary-and-then-from-the-binary-back-to-string
    bitstream = reshape(dec2bin(ascii_text,8).'-'0',1,[]);
    %Print binary_text (optional)
    %fprintf("\n\n");
    %fprintf("%d, ",binary_text);
end