%Example bitstream 
bitstream = [1 0 1 1 0 0 1 1];
%Upsample factor L
upsample_factor = 3;
%Upsampled bitstream length
upsample_length = upsample_factor * length(bitstream);
%Upsample by padding L-1 0s betweeneach sample (element) in bitstream,
%Uses MATLAB function upsample
upsampled_bitstream = upsample(bitstream,upsample_factor);
%Create user upsampled bitstream from function user_upsample
user_upsampled_bitstream = user_upsample(bitstream,upsample_length);
%Test user created upsample-function against MATLAB upsample function
%Output = "" => pass, Output = "fail" => fail
for i = 1 : upsample_length
   if upsampled_bitstream(1,i) ~= user_upsampled_bitstream(1,i)
      fprintf("\nUser-created upsample function failed");
   end
end


%User-created upsample function
function user_upsampled_bitstream = user_upsample(bitstream,upsample_length)
    user_upsampled_bitstream = zeros(1,upsample_length);
    index = 1;
    for i = 1 : length(bitstream)
        user_upsampled_bitstream(1,index) = bitstream(1,i);
        index = index + 1;
        for b = 1 : 2
            user_upsampled_bitstream(1, index) = 0;
            index = index + 1;
        end
    end
end


