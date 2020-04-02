%User-created upsample function
function user_upsampled_bitstream = upsampler(bitstream,upsample_factor,user)
    upsample_length = upsample_factor * length(bitstream);
    if user == true
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
    if user == false
        user_upsampled_bitstream = upsample(bitstream,upsample_factor);
    end
end