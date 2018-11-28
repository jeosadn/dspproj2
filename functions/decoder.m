function decoder(audio_output_filename, N, numBitsMax)
    %N is the # of filter coefficients
    %Variables that must be handled
    levels = 2; %This can be dynamic
    compand_factor = 256; %This is a parameter for the encoder, saved in file for decoder
    sampleFrequency = 8000; %Sample Frequency
    
    %--------------------------------------------------------------------------
    %Read bands and paramaters from binary file
    %--------------------------------------------------------------------------
    binData = read_file('bin/data.bin');
    
    startI = 1;
    endI = (uint32(ceil(numBitsMax/8))*4)+1;
    binDataMax = binData(startI:endI);
    [Max,] = bin_to_int(numBitsMax, 4, binDataMax.', 0);
    
    startI = endI + 1;
    endI = startI + 1;
    binDataW1 = binData(startI:endI);
    [numBits(1),] = bin_to_int(8, 1, binDataW1.', 0);
    
    startI = endI + 1;
    endI = startI + 1;
    binDataW2 = binData(startI:endI);
    [numBits(2),] = bin_to_int(8, 1, binDataW2.', 0);    
    
    startI = endI + 1;
    endI = startI + 1;
    binDataW3 = binData(startI:endI);
    [numBits(3),] = bin_to_int(8, 1, binDataW3.', 0);    
    
    startI = endI + 1;
    endI = startI + 1;
    binDataW4 = binData(startI:endI);
    [numBits(4),] = bin_to_int(8, 1, binDataW4.', 0);    
    
    startI = endI + 1;
    endI = startI + 4;
    binDataSize = binData(startI:endI);
    [sizeResult,] = bin_to_int(32, 1, binDataSize.', 0);
    
    startI = endI + 1;
    endI = startI + ceil((sizeResult*(numBits(1)+1))/8) - 1;
    binData1 = binData(startI:endI);
    [data(1,:),dataS(1,:)] = bin_to_int(numBits(1), sizeResult, binData1.', 1); 
    
    startI = endI + 1;
    endI = startI + ceil((sizeResult*(numBits(2)+1))/8) - 1;
    binData2 = binData(startI:endI);
    [data(2,:),dataS(2,:)] = bin_to_int(numBits(2), sizeResult, binData2.', 1);
    
    startI = endI + 1;
    endI = startI + ceil((sizeResult*(numBits(3)+1))/8) - 1;
    binData3 = binData(startI:endI);
    [data(3,:),dataS(3,:)] = bin_to_int(numBits(3), sizeResult, binData3.', 1);  
    
    startI = endI + 1;
    endI = startI + ceil((sizeResult*(numBits(4)+1))/8) - 1;
    binData4 = binData(startI:endI);
    [data(4,:),dataS(4,:)] = bin_to_int(numBits(4), sizeResult, binData4.', 1);
    
    maxBits = [2^(numBits(1)-1) 2^(numBits(2)-1) 2^(numBits(3)-1) 2^(numBits(4)-1)];
        
    %--------------------------------------------------------------------------
    % Decoding Job
    %--------------------------------------------------------------------------
    split_result = zeros(2^levels,sizeResult);
    %Dequantize
    for i = 1:2^levels        
        for j = 1:sizeResult
            if dataS(i,j) == 1
                split_result(i,j) = -1*data(i,j)*Max(1,i)/maxBits(i);
            else
                split_result(i,j) = data(i,j)*Max(1,i)/maxBits(i);
            end
        end
    end

    %Reverse compansion
    for i = 1:2^levels
        compand_mag(i) = max(split_result(i,:));
        split_result(i,:) = compand(split_result(i,:), compand_factor, compand_mag(i), 'mu/expander');
    end

    %Rejoin bands
    join_result = band_join(split_result, N);

    %Plot joined bands
    figure();
    stem(0:(sampleFrequency-1), abs(fft(join_result(N*2^levels+1:end), sampleFrequency)));
    title(sprintf('Espectro de bandas unidas'));

    
    %--------------------------------------------------------------------------
    % Write audio file
    %--------------------------------------------------------------------------
    %Output characteristics:
    % 16 bit per sample, at 8000 Hz, in stereo
    audiowrite(audio_output_filename, join_result, sampleFrequency);
end
