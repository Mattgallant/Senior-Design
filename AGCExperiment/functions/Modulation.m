%Takes in a file converts to bits and then creates bpsk 4pam and 8pam modulations
%Specify number of bits from source to send(Pick multiples of both 3 and 2)
%Jaino Vennatt
function [BPSKSignal,FourPamSignal,EightPamSignal] = Modulation(sendableBits)
    
    fourPamModValue = mod((length(sendableBits)),2);
    eightPamModValue = mod((length(sendableBits)),3);
    BPSKSignal= zeros(1, length(sendableBits));
    FourPamSignal=zeros(1, ((fix(length(sendableBits))/2)+fourPamModValue));
    EightPamSignal=zeros(1, ((fix(length(sendableBits))/3)+eightPamModValue));

    %Code To assign Values for BPSK
    for n=1:length(sendableBits)

        if(bin2dec(sendableBits(n))==1)
            BPSKSignal(n) =1;
        else
            BPSKSignal(n)=-1;
        end
    end

    %Code To assign Values for 4Pam
    %Constellation : 00  01  11  10
    for n=1:2:length(sendableBits)
        tempArray= zeros(1, 2);
        tempArray(1)=str2num(sendableBits(n));
        tempArray(2)=str2num(sendableBits(n+1));
        tempString= num2str(tempArray);
        value=bin2dec(tempString);
        indexValue=fix(n/2)+1;
        if(value==0)
            FourPamSignal(indexValue)=-3;
        elseif(value==1)
            FourPamSignal(indexValue)=-1;
        elseif(value==3)
            FourPamSignal(indexValue)=1;
        elseif(value==2)
            FourPamSignal(indexValue)=3;
        end
    end


    %Code To assign Values for 8Pam
    %Constellation : 000 001 011 010 110 111 101 100
    for n=1:3:length(sendableBits)
        tempArray= zeros(1, 3);
        tempArray(1)=str2num(sendableBits(n));
        tempArray(2)=str2num(sendableBits(n+1));
        tempArray(3)=str2num(sendableBits(n+2));
        tempString= num2str(tempArray);
        value=bin2dec(tempString);
        indexValue=(((fix(n/3)))+(mod(n,3)));
        if(value==0)
            EightPamSignal(indexValue)=-7;
        elseif(value==1)
            EightPamSignal(indexValue)=-5;
        elseif(value==3)
            EightPamSignal(indexValue)=-3;
        elseif(value==2)
            EightPamSignal(indexValue)=-1;
        elseif(value==6)
            EightPamSignal(indexValue)=1;
        elseif(value==7)
            EightPamSignal(indexValue)=3;
        elseif(value==5)
            EightPamSignal(indexValue)=5;
        elseif(value==4)
            EightPamSignal(indexValue)=7;
        end
    end
    
    
    %Normalize BPSK
    BPSKNormalizingFactor=sqrt(1);
    for n=1:length(BPSKSignal)
        currentvalue=BPSKSignal(n);
        BPSKSignal(n) = currentvalue / BPSKNormalizingFactor;
    end
    
    %Normalize 4PAM
    FourPamNormalizingFactor= sqrt(5);
    for n=1:length(FourPamSignal)
        currentvalue=FourPamSignal(n);
        FourPamSignal(n) = currentvalue / FourPamNormalizingFactor;
    end
    
    %Normalize 8PAM
    EightPamNormalizingFactor= sqrt(21);
    for n=1:length(EightPamSignal)
        currentvalue=EightPamSignal(n);
        EightPamSignal(n) = currentvalue / EightPamNormalizingFactor;
    end
    
    %disp(EightPamSignal);
    
    




