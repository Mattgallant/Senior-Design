%SRRC Script
rng default
%Filter Span in symbol durations
nysm = 6;
%Roll-off factor
beta = 1;
%Samples per symbol, upsampling factor
samplesPerSymbol = 6;
%Data Length in symbols
dataLength = 5e2;
%Data Rate in symbols/sec
dataRate = 500;
%Sampling Frequency in samples/sec
Fs = dataRate * samplesPerSymbol;
%Carrier Frequency in Hz
Fc = 300;

%Design SRRC filter, (optinal) visualize impulse response
srrc = rcosdesign(beta,nysm,samplesPerSymbol,'sqrt');
filter_delay = nysm / (2*dataRate);
%fvtool(srrc,'Analysis','impulse')

%Generate ramdom bitstream
x = randi([0 1],dataLength,1);
%Generate random bipolar data
b_data = x.*2 - 1;
%Upsample bitstream x
x_up = upsample(x,samplesPerSymbol);
%Convert upsampled bitstream to BPSK
x_bpsk = x_up.*2 - 1;

%Filter Bipolar Data with Upsampling
y = upfirdn(b_data,srrc,samplesPerSymbol);
%Filter Pre-upsampled BPSK data
y_bpsk = upfirdn(x_bpsk,srrc);

%Correct for propagation delay
yc = y(filter_delay*Fs + 1:end);
yc_bpsk = y_bpsk(filter_delay*Fs + 1:end);


figure(1)
plot(yc)
axis([-3 300 -2 2])

%figure(2)
%plot(yc_bpsk)
%axis([-3 300 -2 2])

%Convolve with upsampled BPSK symbols
base = conv(x_bpsk,srrc);
base = base(filter_delay*Fs + 1:end);

t = 1000 * (0:dataLength*samplesPerSymbol-1) / Fc;

%Convert to transmit signal
signal = base.*cos(2*pi*t.*Fs);

figure(3)
plot(t(1:300),yc(1:300),'m-'); hold off;
axis([-3 300 -2 2])
xlabel('Time');
ylabel('Amplitude');
legend('SRRC, Upconverted Data','Location','southeast');



