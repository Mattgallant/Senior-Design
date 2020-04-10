function yc = SRRC(b_data,nysm,beta,samplesPerSymbol,dataRate,Fc)
%Design SRRC filter, (optinal) visualize impulse response
srrc = rcosdesign(beta,nysm,samplesPerSymbol,'sqrt');
filter_delay = nysm / (2*dataRate);
%fvtool(srrc,'Analysis','impulse')

%Filter Bipolar Data with Upsampling
y = upfirdn(b_data,srrc,samplesPerSymbol);

%Correct for propagation delay
yc = y(filter_delay*Fs + 1:end);

end