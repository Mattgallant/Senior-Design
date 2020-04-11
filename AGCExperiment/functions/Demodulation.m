%Takes in a file converts to bits and then creates bpsk 4pam and 8pam modulations
%Specify number of bits from source to send(Pick multiples of both 3 and 2)
%Jaino Vennatt
    numberOfBits =12;
    %Open source file
    filePointer= fopen('alice_in_wonderland.txt');
    %Read in characters of book
    fileValues= fscanf(filePointer,'%c');
    %Convert character values to binary
    binaryValues = dec2bin(fileValues);
    %CharactersBeingTested divided by 8 because of size of character is 8bit
    sourceCharacters= fileValues(1:fix(numberOfBits/8)); %in ascii
    %disp(sourceCharacters);
    %Get the number of Rows and Columns of Binary Data
    [rows,columns] = size(binaryValues);
    %Reshapes to one row, and necessary number of Columns
    reshapedBinaryValuesArray= reshape(binaryValues', 1, rows*columns);
    %Creates the array for the number of bits to send 
    characterConversion= reshapedBinaryValuesArray(1:numberOfBits);
    sendableBits= zeros(1,numberOfBits);    
    zeroValue='0';
    oneValue='1';
    %Converts from character binary values to actual double binary values
    %Enables better use of modulation and other number based libraries
    for i=1:1:numberOfBits
        if(strcmp(characterConversion(i),oneValue))
            sendableBits(i)=1;
        elseif(strcmp(characterConversion(i),zeroValue))
            sendableBits(i)=0;
        end        
    end

   
    
    %%Modulation Section%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Grab input paramenter information
    [rows,numberOfEntries] = size(sendableBits);
    disp("Original Array");
    disp(sendableBits);
    
    %%%%%%%%%%%%%%%Create BPSK Signal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BPSKModulator= comm.BPSKModulator;
    %convert to vertical column vector  so BPSK can take in 
    BPSKSignalVector = BPSKModulator(sendableBits(:));
    BPSKModulatedSignal= reshape(BPSKSignalVector,[1,numberOfEntries]);
    %disp(BPSKModulatedSignal);
    
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
    %disp(FourModulatedSignal);
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
    %disp("EightPamSignal");
    
    
    
    %disp(BPSKModulatedSignal);
    disp(FourModulatedSignal);
    
    %disp(EightModulatedSignal);
    
    
    
    inputSignalType="4PAM";
    inputSignal= FourModulatedSignal;
    
    
    
    
   %[demodulatedSignal] = Demodulation(inputSignal, inputSignalType);
    %%%%%%%%%%%%%%%%%Demodulation Section%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BSPKSignalType= "BPSK";
    FourPAMSignalType= "4PAM";
    EightPAMSignalType= "8PAM";
    
    if(strcmp(inputSignalType,BSPKSignalType))
        ModulationOrder=1;
        BPSKDemodulator= comm.BPSKDemodulator;
        demodulatedSignal = BPSKDemodulator(inputSignal(:));
        [rows,numberOfEntries] = size(sendableBits);
    elseif(strcmp(inputSignalType,FourPAMSignalType))
        ModulationOrder=4;
        demodulatedSignal = pamdemod(inputSignal,ModulationOrder);
    elseif(strcmp(inputSignalType,EightPAMSignalType))
        ModulationOrder=8;
        demodulatedSignal = pamdemod(inputSignal,ModulationOrder);
    end
        disp("Demodulated Signal");
        disp(demodulatedSignal);
        
        
    
    

   
    
    
    




