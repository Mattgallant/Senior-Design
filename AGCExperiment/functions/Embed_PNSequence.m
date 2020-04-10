%Embed a PN sequence into bitstream;
% Paramater bitstream - input bitstream
% Parameter splitIndex - Where we want to split bitstream and embed the
% training sequence
function [embeddedStream, training_sequence] = Embed_PNSequence(bitstream, splitIndex)
    % Create Pseudonumber sequence object with certain properties
    pnSequence = comm.PNSequence('Polynomial',[3 2 0],'SamplesPerFrame',7,'InitialConditions',[0 0 1]);

    % Generate the PN training sequence
    training_sequence = pnSequence();
    training_sequence = training_sequence';
    
    % Embed training sequence into bitstream
    s1 = bitstream(1:splitIndex);
    s2 = bitstream(splitIndex+1:end);
    embeddedStream = horzcat(s1,training_sequence,s2);