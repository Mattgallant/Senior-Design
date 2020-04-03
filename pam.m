% seq = pam(len,M,Var);
% Create an M-PAM source sequence with
% length 'len'  and variance 'Var'. Variance seems to be equal to the
% signal power...
function seq=pam(len,M,Var);
    seq=(2*floor(M*rand(1,len))-M+1)*sqrt(3*Var/(M^2-1));
    
    
% This is Matt's explanation of what's going on here...
% rand(1,len) is generating a (len) length sequence between 0 and 1 (not
% inclusive) then multiplying by M. This gives possible values between 0
% and M (not inclusive). Then the value is floored (get rid of the
% decimals) and multiplied by 2. Then subtract (M+1) to get negative values
% of the constellation mapping.
% The sqrt(3*var/m^2 -1)) is normalizing to unit power.. I THINK