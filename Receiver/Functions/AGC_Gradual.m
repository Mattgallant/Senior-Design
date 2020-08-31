%just incase method, KnownFunction was reccomended last semester

function [signal, estimation] = AGC_Gradual(r)
    % AGCGRAD : 
    %   inputs- 
    %       r is the recieved signal that has been attenuated, 
    %   outputs- 
    %       signal is the estimated signal with attenuation removed
    %       estimation is an array containing estimated attenuation
    %       at each step in the gradient descent method
    %
    n=length(r);                            % number of steps in sim is equal to length of signal
    ds=1;                                   % desired power of the algorithm, Javi says to keep it at 1, may be a parameter
    mu=0.01;                                % gradient descent learning rate
    a=zeros(n,1); a(1)=1;                   % initialize AGC vector and initial guess
    s=zeros(n,1);                           % estimation of original            
    for k=1:n-1
        s(k)=a(k)*r(k);                             % normalize by a to get s
        a(k+1)=a(k)-mu*sign((s(k)^2)-(ds^2));       % update a(k+1)
    end
    signal = s;         % estimation of original signal
    estimation = a;     % estimation of attenuation factor over time
end

