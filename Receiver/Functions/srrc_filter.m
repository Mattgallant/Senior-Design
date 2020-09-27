function [yc] = srrc_filter(b_data,nysm,beta,samplesPerSymbol,dataRate)
    %Design SRRC filter, (optinal) visualize impulse response
    srrc = rcosdesign(beta,nysm,samplesPerSymbol,'sqrt');
    %Normalize filter
    srrc = srrc * 1/max(srrc);
    %Calculate filter delay
    filter_delay = nysm / (2*dataRate);
    fvtool(srrc,'Analysis','impulse')

    %Sampling Frequency in samples/sec
    Fs = dataRate * samplesPerSymbol;

    %Filter Bipolar Data with Upsampling
    y = upfirdn(b_data,srrc,samplesPerSymbol);

    %Correct for propagation delay
    yc = y(filter_delay*Fs + 1:end);

    %t = 1000 * (0:length(b_data)*samplesPerSymbol-1) / Fc;
end

