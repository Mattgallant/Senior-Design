%% Params
waveLength = 100;
t = (0:.01:10);
fc = .5;
fo = .5;
po = -pi/2;

%% Create Waves
% Wave w/ no PO or FO
w = 2*pi*fc;
origWave = 2*cos(w*t);

% Wave w/ Freq Offset
newW = 2*pi*(fc+ fc*fo);
disp("Central Freq is: " + fc +"Hz");
disp("Freq offset was: " + fc*fo + "Hz" + " for a new central of: " + (fc + fc*fo) + "Hz");
freqOffWave = 2*cos(newW*t);

% Wave/ w Phase Offset
phaseOffWave = 2*cos(w*t + po);

%% Plot
figure;
plottf(origWave,1);
title("Original")

figure;
plottf(2*sin(w*t),1);
title("Sine");

figure;
plottf(phaseOffWave,1);
title("Phase Offset");

figure;
plottf(freqOffWave,1);
title("Freq Offset Wave");
