function decoder(audio_output_filename, N, numBitsMax)
    %N is the # of filter coefficients
    %Variables that must be handled
    levels = 2; %This can be dynamic
    compand_factor = 256; %This is a parameter for the encoder, saved in file for decoder
    sampleFrequency = 8000; %Sample Frequency
    
    %--------------------------------------------------------------------------
    %Read bands and paramaters from binary file
    %--------------------------------------------------------------------------
    binDataMax = read_file('bin/dataMax.bin');
    binDataW1 = read_file('bin/dataW1.bin');
    binDataW2 = read_file('bin/dataW2.bin');
    binDataW3 = read_file('bin/dataW3.bin');
    binDataW4 = read_file('bin/dataW4.bin');
    binData1 = read_file('bin/data1.bin');
    binData2 = read_file('bin/data2.bin');
    binData3 = read_file('bin/data3.bin');
    binData4 = read_file('bin/data4.bin');
    
    [Max,] = bin_to_int(numBitsMax, 4, binDataMax.', 0);
    [numBits(1),] = bin_to_int(8, 1, binDataW1.', 0);
    [numBits(2),] = bin_to_int(8, 1, binDataW2.', 0);
    [numBits(3),] = bin_to_int(8, 1, binDataW3.', 0);
    [numBits(4),] = bin_to_int(8, 1, binDataW4.', 0);
    
    sizeResult = round(size(binData1,1)*8/(numBits(1)+1));
    maxBits = [2^(numBits(1)-1) 2^(numBits(2)-1) 2^(numBits(3)-1) 2^(numBits(4)-1)];
    
    [data(1,:),dataS(1,:)] = bin_to_int(numBits(1), sizeResult, binData1.', 1);    
    [data(2,:),dataS(2,:)] = bin_to_int(numBits(2), sizeResult, binData2.', 1);    
    [data(3,:),dataS(3,:)] = bin_to_int(numBits(3), sizeResult, binData3.', 1);    
    [data(4,:),dataS(4,:)] = bin_to_int(numBits(4), sizeResult, binData4.', 1);
    
    
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
