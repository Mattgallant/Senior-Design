% y=quantalph(x,alphabet)
%
% quantize the input signal x to the alphabet
% using nearest neighbor method
% input x - vector to be quantized
%       alphabet - vector of discrete values that y can take on
%                  sorted in ascending order
% output y - quantized vector
function y=quantalph(x,alphabet)
    %disp(alphabet);
    alphabet=alphabet(:);
    %disp(alphabet);
    x=x(:);
    %disp(ones(size(x)))
    alpha=alphabet(:,ones(size(x)))';
    %disp(alpha)
    dist=(x(:,ones(size(alphabet)))-alpha).^2; %Calculating the distance of all neighbors
    %disp(dist);
    [v,i]=min(dist,[],2);   %Finding the min distance, stored in the index (i)
    %disp([v, i, dist])
    y=alphabet(i);          %Return the alphabet vector of quantized symbols

