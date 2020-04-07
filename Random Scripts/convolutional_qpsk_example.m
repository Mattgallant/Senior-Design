%% LLR vs. Hard Decision Demodulation
% This example shows the BER performance improvement for QPSK modulation
% when using log-likelihood ratio (LLR) instead of hard-decision
% demodulation in a convolutionally coded communication link. With LLR
% demodulation, one can use the Viterbi decoder either in the unquantized
% decoding mode or the soft-decision decoding mode. Unquantized decoding,
% where the decoder inputs are real values, though better in terms of BER,
% is not practically viable. In the more practical soft-decision decoding,
% the demodulator output is quantized before being fed to the decoder. It
% is generally observed that this does not incur a significant cost in BER
% while significantly reducing the decoder complexity. We validate this
% experimentally through this example.

% Copyright 2006-2018 The MathWorks, Inc.

%% Initialization
% Set these parameters to run the simulation.
%
% * |M|              : Modulation order
% * |k|              : Bits per symbol
% * |bitsPerIter|    : Number of bits to simulate
% * |EbNo|           : Information bit Eb/No in dB
% * |codeRate|       : Code rate of convolutional encoder
% * |constLen|       : Constraint length of encoder
% * |codeGenPoly|    : Code generator polynomial of encoder
% * |tblen|          : Traceback depth of Viterbi decoder
%
%%
% _Simulation parameters_
M = 4;
k = log2(M);
bitsPerIter = 1.2e4;
EbNoVector = 0:.5:10;
berVector = zeros(length(EbNoVector),1);
%%
% _Code properties_
codeRate = 1/2;
constLen = 7;
codeGenPoly = [171 133];
tblen = 32;     
trellis = poly2trellis(constLen,codeGenPoly);

%% 
% Create a rate 1/2, constraint length 7 |<docid:comm_ref#bsnfrdn_3
% ConvolutionalEncoder>| System object(TM).
enc = comm.ConvolutionalEncoder(trellis);
%% 
% *Modulator and Channel*
%
% Create a |<docid:comm_ref#bsnfizy_6 QPSKModulator>| object and two
% |<docid:comm_ref#bsnfizx_7 QPSKDemodulator>| objects. Configure the first
% demodulator to output hard-decision bits. Configure the second to output
% LLR values.
qpskMod = comm.QPSKModulator('BitInput',true);
demodHard = comm.QPSKDemodulator('BitOutput',true,...
    'DecisionMethod','Hard decision');
demodLLR = comm.QPSKDemodulator('BitOutput',true,...
    'DecisionMethod','Log-likelihood ratio');
%%
% Create an |<docid:comm_ref#buiamu7-1 AWGNChannel>| object. The signal
% going into the AWGN channel is the modulated encoded signal. To achieve
% the required noise level, adjust the Eb/No for coded bits and multi-bit
% symbols. Set this as the |EbNo| of the channel object.
for ebnoi = 1:length(EbNoVector)
EbNo = EbNoVector(ebnoi);
chan = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (Eb/No)', ...
    'BitsPerSymbol',k);
EbNoCoded = EbNo + 10*log10(codeRate);
chan.EbNo = EbNoCoded;
%% 
% *Viterbi Decoding*
%
% Create |<docid:comm_ref#bsnfpwn_4 ViterbiDecoder>| objects to act as the
% hard-decision, unquantized, and soft-decision decoders. For all three
% decoders, set the traceback depth to |tblen|.
decHard = comm.ViterbiDecoder(trellis, 'InputFormat', 'Hard',...
    'TracebackDepth',tblen); 

decUnquant = comm.ViterbiDecoder(trellis,'InputFormat','Unquantized', ...
    'TracebackDepth',tblen); 

decSoft = comm.ViterbiDecoder(trellis,'InputFormat','Soft', ...
    'SoftInputWordLength',3,'TracebackDepth',tblen); 

%%
% *Quantization for soft-decoding*
%
% Before using a |comm.ViterbiDecoder| object in the soft-decision mode,
% the output of the demodulator needs to be quantized. This example uses a
% |comm.ViterbiDecoder| object with a |SoftInputWordLength| of 3. This
% value is a good compromise between short word lengths and a small BER
% penalty. Create a |<docid:dsp_ref#bsfy7o7_5 ScalarQuantizerEncoder>| object
% with 3-bit quantization.
scalQuant = dsp.ScalarQuantizerEncoder('Partitioning','Unbounded');
snrdB = EbNoCoded + 10*log10(k);
NoiseVariance = 10.^(-snrdB/10);
demodLLR.Variance = NoiseVariance;
scalQuant.BoundaryPoints = (-1.5:0.5:1.5)/NoiseVariance;

%% 
% *Calculating the Error Rate*
%
% Create |<docid:comm_ref#bsnan5l_3 ErrorRate>| objects to compare the
% decoded bits to the original transmitted bits. The Viterbi decoder
% creates a delay in the decoded bit stream output equal to the traceback
% length. To account for this delay, set the |ReceiveDelay| property of the
% |comm.ErrorRate| objects to |tblen|.
errHard = comm.ErrorRate('ReceiveDelay',tblen);
errUnquant = comm.ErrorRate('ReceiveDelay',tblen);
errSoft = comm.ErrorRate('ReceiveDelay',tblen);

%% System Simulation
%%
% Generate |bitsPerIter| message bits.
txData = randi([0 1],bitsPerIter,1);
%%
% Convolutionally encode the data.
encData = enc(txData);
%%    
% Modulate the encoded data.
modData = qpskMod(encData);
%%    
% Pass the modulated signal through an AWGN channel.
rxSig = chan(modData);
%%
% Demodulate the received signal and output hard-decision bits.
hardData = demodHard(rxSig); 
%%
% Demodulate the received signal and output LLR values.
LLRData = demodLLR(rxSig);
%%                
% _Hard-decision decoding_
%
% Pass the demodulated data through the Viterbi decoder. Compute the error
% statistics.
rxDataHard = decHard(hardData);
berHard = errHard(txData,rxDataHard);
%%
% _Unquantized decoding_
%
% Pass the demodulated data through the Viterbi decoder. Compute the error
% statistics.
rxDataUnquant = decUnquant(LLRData);
berUnquant = errUnquant(txData,rxDataUnquant);
%%        
% _Soft-decision decoding_
%
% Pass the demodulated data to the quantizer. This data must be multiplied
% by |-1| before being passed to the quantizer, because, in soft-decision
% mode, the Viterbi decoder assumes that positive numbers correspond to 1s
% and negative numbers to 0s. Pass the quantizer output to the Viterbi
% decoder. Compute the error statistics.
quantizedValue = scalQuant(-LLRData);
rxDataSoft = decSoft(double(quantizedValue));
berSoft = errSoft(txData,rxDataSoft);

berVector(ebnoi) = berSoft(1);


end

figure(2)
semilogy(EbNoVector, berVector)
title('Coded QPSK')
xlabel('SNR (dB)')
ylabel('BER')

%% Running Simulation Example
% Simulate the previously described communications system over a range of
% Eb/No values by executing the simulation file |simLLRvsHD|. It plots BER
% results as they are generated. BER results for hard-decision demodulation
% and LLR demodulation with unquantized and soft-decision decoding are
% plotted in red, blue, and black, respectively. A comparison of simulation
% results with theoretical results is also shown. Observe that the BER is
% only slightly degraded by using soft-decision decoding instead of
% unquantized decoding. The gap between the BER curves for soft-decision
% decoding and the theoretical bound can be narrowed by increasing the
% number of quantizer levels. 
%
% This example may take some time to compute BER results. If you have the
% Parallel Computing Toolbox(TM) (PCT) installed, you can set usePCT to
% true to run the simulation in parallel. In this case, the file
% |LLRvsHDwithPCT| is run. 
%
% To obtain results over a larger range of Eb/No values, modify the
% appropriate supporting files. Note that you can obtain more statistically
% reliable results by collecting more errors.
%
% usePCT = false;
% if usePCT && license('checkout','Distrib_Computing_Toolbox') && ~isempty(ver('parallel'))
%     LLRvsHDwithPCT(1.5:0.5:5.5,5);
% else
%     simLLRvsHD(1.5:0.5:5.5,5);
% end

%% Appendix
% The following functions are used in this example:
%
% * <matlab:edit('simLLRvsHD.m') simLLRvsHD.m>: Simulates system without
% PCT.
% * <matlab:edit('LLRvsHDwithPCT.m') LLRvsHDwithPCT.m>: Simulates system
% with PCT.
% * <matlab:edit('simLLRvsHDPCT.m') simLLRvsHDPCT.m>: Helper function
% called by LLRvsHDwithPCT.


%displayEndOfDemoMessage(mfilename)

