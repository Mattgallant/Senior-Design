Lh = 200;                        % Impulse response length
Fpb = 2400;                     % Passband Edge in Hz
Fsb = 2900;                     % Stopband edge in Hz
Fs = 44100;


h = firlpf(Lh, Fpb, Fsb ,Fs);
figure;plottf(h,1/Fs);% view signal
title('Filter')

