%EbNo input sequence
EbNo =  (-2:0.2:10)';
%Frames per EbNo value
frames = 100;

%LDPC QPSK
ber_qpskLDPC = qpskLDPC(EbNo,frames);

%LDPC 16QAM
ber_qam16LDPC = qam16LDPC(EbNo,frames);

%LDPC 64QAM
ber_qam64LDPC = LDPC64QAM(EbNo,frames);

figure(1)
semilogy(EbNo,ber_qam16LDPC,'-m*') 
hold on
semilogy(EbNo,ber_qam64LDPC,'-b*');
hold on
semilogy(EbNo,ber_qpskLDPC,'-g*');
hold on
semilogy(EbNo,berawgn(EbNo,'qam',16),'-m')
hold on
semilogy(EbNo,berawgn(EbNo,'qam',64),'-b')
hold on
semilogy(EbNo,berawgn(EbNo,'psk',4,'nodiff'),'-g')
legend('16QAM LDPC','64QAM LDPC','QPSK LDPC','16QAM berawgn Uncoded','64QAM berawgn Uncoded','QPSK berawgn Uncoded','location','best')
grid
xlabel('Eb/No (dB)')
ylabel('Bit Error Rate')
