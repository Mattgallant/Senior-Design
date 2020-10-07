%% LVL 0
%  Input Data, TXT-To-Bitstream, Bitstream-to-TXT

%% Input Data (Text File, String)
    file_pointer= fopen("lorem.txt");   %Open file to read from
    read_length_characters = 2000;

%% Bitstream Conversion (Jaino)
% text_to_bitstream
    [source_characters, sendable_bits] = text_to_bitstream(file_pointer, read_length_characters);
%     [text] = bitstream_to_text(sendable_bits);
    
%% Convert Bits to Text (Jaino)
%   Bitstream_to_Text()
    text = Bitstream_to_Text(sendable_bits);
    disp(text)