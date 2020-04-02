# Senior-Design
<b>./functions contains pure functions in .m format callable by anyone </b> </br> </br>
<b>upsampler(bitstream, upsample_factor, (optional) user)</b> </br>
arg bitstream: array of 0s and 1s with row size = 1 </br>
arg upsample_factor: the upsample factor = L, creating a 0 padding of L-1 length between bitstream elements </br>
(optional) arg user: true: use the user-created upsample function, false: use the MATLAB upsample code </br
example usage: upsampled_bitstream = upsampler(1010, 3) </br>
example output: upsampled bitstream => 100000100000 </br>
</br>
<b>file_bitstream(filename,(optional) read_length) </b> </br>
arg filename: the name of the local file to read in ASCII chars from </br>
(optional) arg read_length: the amount of chars to read, default or 0 reads the whole file </br>
example usage: bitstream = file_bitstream("Quijote.txt",5) </br>
example output: bitstream => 0101010001101000011001010101000001110010 </br>



    
