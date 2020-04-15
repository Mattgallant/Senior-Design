


function [BPSKModulatedSignal,FourModulatedSignal, EightModulatedSignal] = Modulation(sendableBits)
    %%Modulation Section%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    %Grab input paramenter information
    [~,numberOfEntries] = size(sendableBits);
    %disp("Original Array");
    %disp(sendableBits);
    
    %%%%%%%%%%%%%%%Create BPSK Signal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BPSKModulator= comm.BPSKModulator;
    %convert to vertical column vector  so BPSK can take in 
    BPSKSignalVector = BPSKModulator(sendableBits(:));
    BPSKModulatedSignal= reshape(BPSKSignalVector,[1,numberOfEntries]);
    %disp("BPSK Signal")
    
    %%%%%%%%%%%%%%%Create 4PAM Signal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FourPamModulationOrder = 4;
    numberOfEntries4Pam=fix(numberOfEntries/2);
    numberLeftOver=mod(numberOfEntries,2);
    if(numberLeftOver~=0)
        numberOfEntries4Pam=numberOfEntries4Pam+1;
    end
    FourPamSignal = zeros(1,numberOfEntries4Pam);
    for i=1:2:numberOfEntries
        if(i+1>numberOfEntries)
            tempArray = zeros(1,2);
            tempArray(1)=sendableBits(i);
            sum = bi2de(tempArray,'left-msb');
            FourPamSignal(fix(i/2)+1)=sum;
            %fix code to make specific temp array that works allowing for
            %any value input
            continue
        end
        tempArray = zeros(1,2);
        tempArray(1)=sendableBits(i);
        tempArray(2)=sendableBits(i+1);
        sum = bi2de(tempArray,'left-msb');
        FourPamSignal(fix(i/2)+1)=sum;
    end
    %disp(FourPamSignal);
    FourModulatedSignal = pammod(FourPamSignal,FourPamModulationOrder);
    %disp("4PAM Signal");
    %disp(FourPamSignal)
    %disp(FourModulatedSignal);
    
    %%%%%%%%%%%%%%%Create 8PAM Signal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %1 4 7 10 13 16
    %1 2 3 4 5 6
    EightPamModulationOrder = 8;
    numberOfEntries8Pam=fix(numberOfEntries/3);
    numberLeftOver=mod(numberOfEntries,3);
    if(numberLeftOver~=0)
        numberOfEntries8Pam=numberOfEntries8Pam+1;
    end
    EightPamSignal = zeros(1,numberOfEntries8Pam);
    for i=1:3:numberOfEntries
        if(i+1>numberOfEntries)
            tempArray = zeros(1,3);
            tempArray(1)=sendableBits(i);
            sum = bi2de(tempArray,'left-msb');
            EightPamSignal(fix(i/3)+1)=sum;
            %fix code to make specific temp array that works allowing for
            %any value input
            continue
        end
        if(i+2>numberOfEntries)
            tempArray = zeros(1,3);
            tempArray(1)=sendableBits(i);
            tempArray(2)=sendableBits(i+1);
            sum = bi2de(tempArray,'left-msb');
            EightPamSignal(fix(i/3)+1)=sum;
            %fix code to make specific temp array that works allowing for
            %any value input
            continue
        end
        tempArray = zeros(1,3);
        tempArray(1)=sendableBits(i);
        tempArray(2)=sendableBits(i+1);
        tempArray(3)=sendableBits(i+2);
        sum = bi2de(tempArray,'left-msb');
        EightPamSignal(fix(i/3)+1)=sum;
    end
    EightModulatedSignal = pammod(EightPamSignal,EightPamModulationOrder);
    %disp(EightModulatedSignal);

    




