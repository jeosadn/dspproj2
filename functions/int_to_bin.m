function result = int_to_bin(numBits, sizeResult, data, dataS, sigValid)
    binArrays = zeros(numBits,sizeResult);
    
    for i = 1:sizeResult
        temp = de2bi(data(i));
        for j = 1:size(temp,2)
           binArrays(j,i) = temp(j); 
        end
    end

    binData = zeros(1,ceil(sizeResult*(numBits+1)/8));
    binData = uint8(binData);
    index = 1;
    cnt = 1;
    
    for i = 1:sizeResult
        if (sigValid == 1)
            md = mod(cnt,8);
            if (md == 0)
                md = 8;
            end
            if (dataS(i))
                binData(1,index) = bitset(binData(1,index),md); 
            end

            cnt = cnt+1;
            if (mod(cnt-1,8) == 0)
                index = index+1;
            end
        end

        for j = 1:numBits            
            if (binArrays(j,i) == 1)
                md = mod(cnt,8);
                if (md == 0)
                    md = 8;
                end
                binData(1,index) = bitset(binData(1,index),md);
            end
            
            cnt = cnt+1;
            if (mod(cnt-1,8) == 0)
                index = index+1;
            end         
        end
    end
    
    result = binData;
end