%EbNo input sequence
EbNo =  (-2:0.2:10)';
%Frames per EbNo value
frames = 1;

%16QAM Turbo Code
ber_Turbo16QAM = Turbo16QAM(EbNo,frames);

%QPSK Turbo Code
