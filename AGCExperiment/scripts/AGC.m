
desiredPower=[0.5, 1, 2];                           % desired power of output
n=100;                           % size of the input bit string                   
r=randn(n,1);                       % random input bit string from transmitter
mu=0.001;                           % learning rate
for i=1:length(desiredPower) 
    ds = desiredPower(i);               % desired power
    a=zeros(n,1); a(1)=1;              % initialize AGC parameter
    s=zeros(n,1);                      % initialize outputs             
    for k=1:n-1
      s(k)=a(k)*r(k);                       % normalize by a to get s
      a(k+1)=a(k)-mu*sign((s(k)^2)-(ds^2));       % average adaptive update of a(k)
    end

    text = sprintf('Adaptive Gain power target: %f', ds);
    figure(i)
    plot(a)
    title(text)
end