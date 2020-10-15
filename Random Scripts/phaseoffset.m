waveLength = 100;
t = (0:0.01:10);
w = 2*pi*9000;
wave = 2*cos(2*pi*.5*t);

% pfo = comm.PhaseFrequencyOffset('FrequencyOffset',1000, 'PhaseOffset', 45);
t = (1:length(wave))';
phaseOff = ( 2*pi*.9*t);

noisyData = wave.'.*exp(1j*phaseOff);
% noisyData = single(awgn(wave.*exp(1j*phaseOff), 10));

outSig = CarrierFrequencyOffset(noisyData');

% new_wave = step(pfo,wave);
% % new_wave = pfo(wave);

figure;
plot(t,noisyData(1:end));
title("Wave w/ offset");
figure;
plot(t, wave(1:end));
title("Original wave");
figure;
plot(t, outSig);
title("Fixed?");