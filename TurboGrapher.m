%EbNo input sequence
EbNo =  (-2:0.2:10)';
%Frames per EbNo value
frames = 1;

%16QAM Turbo Code
ber_Turbo16QAM = Turbo16QAM(EbNo,frames);

%QPSK Turbo Code
ber_TurboQPSK = TurboQPSK(EbNo,frames);

figure(1)
semilogy(EbNo,ber_Turbo16QAM,'-m*') 
hold on
semilogy(EbNo,ber_TurboQPSK,'-b*');
hold on
semilogy(EbNo,berawgn(EbNo,'qam',16),'-m')
hold on
semilogy(EbNo,berawgn(EbNo,'psk',4,'nodiff'),'-g')
legend('16QAM Turbo','QPSK Turbo','16QAM berawgn Uncoded','QPSK berawgn Uncoded','location','best')
grid
xlabel('Eb/No (dB)')
ylabel('Bit Error Rate')
