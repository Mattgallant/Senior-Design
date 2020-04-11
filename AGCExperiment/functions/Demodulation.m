
   [demodulatedSignal] = Demodulation(inputSignalType, inputSignal);
    %%%%%%%%%%%%%%%%%Demodulation Section%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BSPKSignalType= "BPSK";
    FourPAMSignalType= "4PAM";
    EightPAMSignalType= "8PAM";
    
    if(strcmp(inputSignalType,BSPKSignalType))
        ModulationOrder=1;
        BPSKDemodulator= comm.BPSKDemodulator;
        demodulatedSignal = BPSKDemodulator(inputSignal(:));
        [rows,numberOfEntries] = size(demodulatedSignal);
        demodulatedSignal= demodulatedSignal.';

    elseif(strcmp(inputSignalType,FourPAMSignalType))
        ModulationOrder=4;
        tempSignal = pamdemod(inputSignal,ModulationOrder);
        [rows,numberOfEntries] = size(tempSignal);
        demodulatedSignal = zeros(1,numberOfEntries*2);
        disp("Demodulatedtemp");
        disp(tempSignal);
        
        for i=0:1:numberOfEntries-1
            if(tempSignal(i+1)==0)
              demodulatedSignal((i*2)+1)=0;
              demodulatedSignal((i*2)+2)=0;
                
            elseif(tempSignal(i+1)==1)
              demodulatedSignal((i*2)+1)=0;
              demodulatedSignal((i*2)+2)=1;
            elseif(tempSignal(i+1)==2)
              demodulatedSignal((i*2)+1)=1;
              demodulatedSignal((i*2)+2)=0;
                
            elseif(tempSignal(i+1)==3)
              demodulatedSignal((i*2)+1)=1;
              demodulatedSignal((i*2)+2)=1;
            end
        end

    elseif(strcmp(inputSignalType,EightPAMSignalType))
        ModulationOrder=8;
        tempSignal = pamdemod(inputSignal,ModulationOrder);
        [rows,numberOfEntries] = size(tempSignal);
        demodulatedSignal = zeros(1,numberOfEntries*3);
        disp("Demodulatedtemp8");
        disp(tempSignal);
        
        for i=0:1:numberOfEntries-1
            
            if(tempSignal(i+1)==0)
              demodulatedSignal((i*3)+1)=0;
              demodulatedSignal((i*3)+2)=0;
              demodulatedSignal((i*3)+3)=0;
                
            elseif(tempSignal(i+1)==1)
              demodulatedSignal((i*3)+1)=0;
              demodulatedSignal((i*3)+2)=0;
              demodulatedSignal((i*3)+3)=1;
            
            elseif(tempSignal(i+1)==2)
              demodulatedSignal((i*3)+1)=0;
              demodulatedSignal((i*3)+2)=1;
              demodulatedSignal((i*3)+3)=0;
              
            elseif(tempSignal(i+1)==3)
              demodulatedSignal((i*3)+1)=0;
              demodulatedSignal((i*3)+2)=1;
              demodulatedSignal((i*3)+3)=1;
              
            elseif(tempSignal(i+1)==4)
              demodulatedSignal((i*3)+1)=1;
              demodulatedSignal((i*3)+2)=0;
              demodulatedSignal((i*3)+3)=0;  
            elseif(tempSignal(i+1)==5)
              demodulatedSignal((i*3)+1)=1;
              demodulatedSignal((i*3)+2)=0;
              demodulatedSignal((i*3)+3)=1;
            elseif(tempSignal(i+1)==6)
              demodulatedSignal((i*3)+1)=1;
              demodulatedSignal((i*3)+2)=1;
              demodulatedSignal((i*3)+3)=0;
            elseif(tempSignal(i+1)==6)
              demodulatedSignal((i*3)+1)=1;
              demodulatedSignal((i*3)+2)=1;
              demodulatedSignal((i*3)+3)=1;
            end
        end
    end

        
    
    

   
    
    
    




