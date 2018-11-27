function [result0, result1] = bin_to_int(numBits, sizeResult, binData, sigValid)
    binArrays = zeros(sizeResult,numBits);
    dataS = zeros(1,sizeResult);
    data = zeros(1,sizeResult);
    
    cnt = 1;
    index = 1;
    
    for i = 1:sizeResult
        if(sigValid == 1)
            md = mod(cnt,8);
            if (md == 0)
                md = 8;
            end
        
            dataS(1,i) = bitget(binData(index),md);
        
            cnt = cnt+1;
            if (mod(cnt-1,8) == 0)
                index = index+1;
            end
        end
        
        for j = 1:numBits
            md = mod(cnt,8);
            if (md == 0)
                md = 8;
            end
            
            if (bitget(binData(index),md))
                binArrays(i,j) = 1;
            end
                        
            cnt = cnt+1;
            if (mod(cnt-1,8) == 0)
                index = index+1;
            end              
        end
    end
    
    for i = 1:sizeResult
        data(1,i) = bi2de(binArrays(i,:));
    end
    
    result0 = data;
    result1 = dataS;
end