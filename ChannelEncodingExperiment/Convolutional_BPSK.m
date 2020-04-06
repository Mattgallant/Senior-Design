% This is no longer in use! We switched from BPSK to QPSK. See new file.
% Matt's part of the channel encoding risk reduction experiment. This is not currently done. 
% Need to figure out how to change coding rate using LTE Toolbox
% Source: https://www.mathworks.com/help/lte/ref/lteconvolutionaldecode.html

%Generate random bit stream
txBits = randi([0 1],100,1);
disp(txBits)
%Encode data
codedData = lteConvolutionalEncode(txBits);

%Modulate the codeded bits then add noise
txSym = lteSymbolModulate(codedData,'BPSK');
%noise = .5*complex(randn(size(txSym)),randn(size(txSym)));
%y = x + sqrt(var)*randn(1,length(x));
rxSym = txSym + noise;

%xylimits = [-2.5 2.5];
%cdScope = comm.ConstellationDiagram('ReferenceConstellation',txSym,'XLimits',xylimits ,'YLimits',xylimits);
%cdScope(rxSym)

softBits = lteSymbolDemodulate(rxSym,'BPSK','Soft');
out = lteConvolutionalDecode(softBits);
disp(sum(out ~= int8(txBits)))
