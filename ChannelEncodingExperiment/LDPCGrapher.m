%EbNo input sequence
EbNo =  (-2:0.25:10)';
%Frames per EbNo value
frames = 1;

%LDPC QPSK

%LDPC 16QAM
ber_qam16LDPC = qam16LDPC(EbNo,frames);

%LDPC 64QAM

figure(1)
semilogy(EbNo,ber_qam16LDPC,'-m*') 
hold on
semilogy(berawgn(EbNo,'qam',16),'-m')
legend('16QAM LDPC','16QAM berawgn Uncoded','location','best')
grid
xlabel('Eb/No (dB)')
ylabel('Bit Error Rate')
