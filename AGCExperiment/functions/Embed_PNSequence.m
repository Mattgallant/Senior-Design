%Embed a PN sequence into the beginning of bitstream;
% Paramater bitstream - input bitstream
function [embeddedStream, training_sequence] = Embed_PNSequence(bitstream)
    % Create Pseudonumber sequence object with certain properties
    pnSequence = comm.PNSequence('Polynomial',[7 2 0],'SamplesPerFrame',128,'InitialConditions',[0 0 0 0 0 0 1]);

    % Generate the PN training sequence
    training_sequence = pnSequence();
    training_sequence = training_sequence';
    for bit = 1: length(training_sequence)
       if training_sequence(bit)== 0
            training_sequence(bit) = -1;
        end
    end
    % Embed training sequence into bitstream
    embeddedStream = horzcat(training_sequence, bitstream);