function encoder(audio_input_filename, N, numBits, numBitsMax)
    %N is the # of filter coefficients
    %Variables that must be handled
    levels = 2; %This can be dynamic
    compand_factor = 256; %This is a parameter for the encoder, saved in file for decoder
    
    %--------------------------------------------------------------------------
    % Read audio File
    %--------------------------------------------------------------------------
    %Input characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    [sampleData, sampleFrequency] = audioread(audio_input_filename);
    if mod(length(sampleData), 2^levels) ~= 0;
        sampleData(end+1:end+2^levels-mod(end, 2^levels)) = 0;
    end
    
    %Plot sample input
    figure();
    stem(0:(sampleFrequency-1), abs(fft(sampleData, sampleFrequency)));
    title(sprintf('Espectro señal muestreada a %d Hz', sampleFrequency));
    
    %--------------------------------------------------------------------------
    % Encoding Job
    %--------------------------------------------------------------------------
    %Split in bands
    split_result = band_split(sampleData.', N, levels);
    
    %Compand each band
    compand_mag = zeros(1,2^levels);
    compand_result = split_result;
    for i = 1:2^levels
        compand_mag(i) = max(compand_result(i,:));
        compand_result(i,:) = compand(compand_result(i,:), compand_factor, compand_mag(i), 'mu/compressor');
    end
    
    %Plot split bands
    %for i = 1:size(split_result, 1)
        %figure();
        %plot(split_result(i,:));
        %stem(0:((sampleFrequency/2^levels)-1), abs(fft(split_result(i,N+1:end), (sampleFrequency/2^levels))));
        %title(sprintf('Espectro de banda %d', i))
    %end
    
    %Quantization
    sizeResult = size(compand_result,2);
    maxBits = [2^(numBits(1)-1) 2^(numBits(2)-1) 2^(numBits(3)-1) 2^(numBits(4)-1)];
    data = zeros(2^levels,sizeResult);
    dataS = zeros(2^levels,sizeResult);
    Max = zeros(1,2^levels);
    
    for i = 1:2^levels
        Max(1,i) = uint64(round(abs(max(compand_result(i,:)))));
        if (abs(min(compand_result(i,:))) > Max)
            Max(1,i) = uint64(round(abs(min(compand_result(i,:)))));
        end

        for j = 1:sizeResult
            s = 0;
            data_coded = 0;
            if (compand_result(i,j) < 0)
                s = 1;
                data_coded = abs(compand_result(i,j))*maxBits(i)/Max(1,i);
            else
                data_coded = abs(compand_result(i,j))*maxBits(i)/Max(1,i);
            end
            data(i,j) = round(data_coded);
            dataS(i,j) = s;
        end
    end

    %--------------------------------------------------------------------------
    %Save bands and parameteres to binary file
    %--------------------------------------------------------------------------
    binDataMax  = int_to_bin(numBitsMax, 4, Max(1,:), 0, 0);
    binDataW1   = int_to_bin(8, 1, numBits(1), 0, 0);
    binDataW2   = int_to_bin(8, 1, numBits(2), 0, 0);
    binDataW3   = int_to_bin(8, 1, numBits(3), 0, 0);
    binDataW4   = int_to_bin(8, 1, numBits(4), 0, 0);
    binDataSize = int_to_bin(32, 1, sizeResult, 0, 0);
    binData1    = int_to_bin(numBits(1), sizeResult, data(1,:), dataS(1,:), 1);    
    binData2    = int_to_bin(numBits(2), sizeResult, data(2,:), dataS(2,:), 1);    
    binData3    = int_to_bin(numBits(3), sizeResult, data(3,:), dataS(3,:), 1);    
    binData4    = int_to_bin(numBits(4), sizeResult, data(4,:), dataS(4,:), 1);    
 
    binData = [binDataMax binDataW1 binDataW2 binDataW3 binDataW4 binDataSize binData1 binData2 binData3 binData4];
    write_file('bin/data.bin',binData);
    
end
