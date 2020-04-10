% AGC_golay_sequence_detection
% Detect Ga sequence within reveived signal

function[]= golay_sequence_detection(data, header)
    y=xcorr(header, data);                 % do cross correlation
    [m,ind]=max(y);                        % location of largest correlation
    headstart=length(data)-ind+1;          % place where header starts
    if ( loc == headstart )
        totalCorrect = totalCorrect + 1;
    end

    totalCorrect / totalRuns;
    subplot(4,1,1), stem(header)           % plot header
    title('Header')
    subplot(4,1,2), stem(data)             % plot data sequence
    title('Data with embedded header')
    subplot(4,1,3), stem(y)                % plot correlation
    title('Correlation of header with data')
    subplot(4,1,4),plot(abs(xcorr(data,header).^2))
    title('Correlation of header with data')