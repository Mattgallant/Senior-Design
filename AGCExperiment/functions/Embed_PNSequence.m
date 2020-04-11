%Embed a PN sequence into the beginning of bitstream;
% Paramater bitstream - input bitstream
function [embeddedStream] = Embed_PNSequence(bitstream)
    % Create Pseudonumber sequence object with certain properties
    pnSequence = comm.PNSequence('Polynomial',[5 2 0],'SamplesPerFrame',32,'InitialConditions',[0 0 0 0 1]);

    % Generate the PN training sequence
    training_sequence = pnSequence();
    training_sequence = training_sequence';
    
    % Embed training sequence into bitstream
    embeddedStream = horzcat(training_sequence, bitstream);