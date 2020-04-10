function [signal, estimation] = AGCgrad(r)
    %AGCGRAD : 
    %   Detailed explanation goes here
    n=length(r);                           % number of steps in simulation
    ds=1;                                   % desired power of output
    mu=0.01;                                % algorithm stepsize
    a=zeros(n,1); a(1)=1;                   % initialize AGC parameter
    s=zeros(n,1);                           % estimation of original             
    for k=1:n-1
        s(k)=a(k)*r(k);                       % normalize by a to get s
        a(k+1)=a(k)-mu*sign((s(k)^2)-(ds^2));       % average adaptive update of a(k)
    end
    signal = s;
    estimation = a;
end

