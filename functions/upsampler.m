%User-created upsample function
%if the arguement 'user' is not passed, user defaults to true
function user_upsampled_bitstream = upsampler(bitstream,upsample_factor,user)
    upsample_length = upsample_factor * length(bitstream);
    if nargin == 2
       user = true;
    end
    if user == true
        user_upsampled_bitstream = zeros(upsample_length,1);
        index = 1;
        for i = 1 : length(bitstream)
            user_upsampled_bitstream(index,1) = bitstream(i,1);
            index = index + 1;
            for b = 1 : 2
                user_upsampled_bitstream(index,1) = 0;
                index = index + 1;
            end
        end
    end
    if user == false
        user_upsampled_bitstream = upsample(bitstream,upsample_factor);
    end
end