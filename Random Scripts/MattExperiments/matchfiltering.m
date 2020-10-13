% Messing around and learning SRRC + Match filtering
D = 10;          % Truncation Half-Width
L = 10;         % Upsampling Factor
a = .25;        % Excess Bandwith, larger a spreads the freq content to larger bandwidth but lowers ISI

srrc_filter = srrc(D, a, L);
figure;
plottf(srrc_filter, 1);

figure;
plottf(conv(srrc_filter, srrc_filter), 1);
