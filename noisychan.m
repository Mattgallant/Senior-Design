% The following Matlab program explores a noisy system. A sequence of four level
% data (4-PAM) is generated by calling the pam.m routine. Noise is then added with
% power specified by p (power of the noise), and the number of errors caused by this amount of noise
% is calculated in err.

m=1000;                                 % length of data sequence
p=1/15; s =1.0;                         % power of noise and signal --> SNR = s/p. Higher signal power = lower bit error rate
x=pam(m, 4 , s ) ;                      % 4?PAM input with power 1 . . . SEE PAM FUNCTION
L=sqrt ( 1 / 5 ) ;                      % ...with amp levels L
n=sqrt (p)*randn(1 ,m) ;                % noise with power p
y=x+n ;                                 % output adds noise to data
qy=quantalph(y,[-3*L,-L,L,3*L]) ;       % quantize to [?3*L,?L,L,3*L]   SEE QUANTALPH FUNCTION
err=sum(abs(sign(qy'-x )))/m;           % percent transmission errors    

disp("Error rate is " + err)
disp("SNR is " + s/p)
%disp(err)
%disp(sum(x)/m)