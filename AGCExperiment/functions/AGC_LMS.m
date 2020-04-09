%-----AGC_LMS------
%Stabilizes the amplitude of a received signal
%Inputs: r - the signal to be equalized
%Outputs: output - the signal after amplitude equalization
function output = AGC_LMS(r)
    n=length(r);                           % number of steps in simulation
    ds=1;                           % desired power of output
%     env=0.75+abs(sin(2*pi*[1:n]'/n));  % the fading profile
%     r=r.*env;                          % apply to raw input r[k]
    mu=0.01;                          % algorithm stepsize
    
%code from https://www.allaboutcircuits.com/technical-articles/adaptive-gain-control-with-the-least-mean-squares-algorithm/
    ref = 1;    % desired output !!!!!!! should this also be a parameter?

    DivideByFactor = 1; %initial
    
    for k = 1:n
        y(k) =  r(k) * DivideByFactor;
        y_mag = abs(y(k));
        err(k) = ref - y_mag;
        DivideByFactor_time(k) = DivideByFactor ;
        DivideByFactor = DivideByFactor +mu*err(k);
    end
    
    output = y; %y is 

%     % % % draw agcgrad.eps
%     subplot(3,1,1)
%     plot(DivideByFactor_time)              % plot AGC values
%     title('Adaptive gain parameter')
%     subplot(3,1,2)
%     plot(r,'r')          % plot inputs and outputs
%     axis([0,10^4,-5,5])
%     title('Input r(k)')
%     subplot(3,1,3)
%     plot(y,'b')
%     axis([0,10^4,-5,5])
%     title('Output y(k)')
%     xlabel('iterations')

end



