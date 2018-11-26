function encoder(audio_input_filename, audio_output_filename, N)
    %N is the # of filter coefficients
    %Variables that must be handled
    levels = 2; %This can be dynamic
    compand_factor = 256; %This is a parameter for the encoder, saved in file for decoder
    %compand_mag = [1 1 1 1]; %This is a parameter for the encoder, saved in file for decoder
    
    %--------------------------------------------------------------------------
    % Read audio File
    %--------------------------------------------------------------------------
    %Input characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    [sampleData, sampleFrequency] = audioread(audio_input_filename);
    
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
    for i = 1:size(split_result, 1)
        figure();
        plot(split_result(i,:));
        stem(0:((sampleFrequency/2^levels)-1), abs(fft(split_result(i,N+1:end), (sampleFrequency/2^levels))));
        title(sprintf('Espectro de banda %d', i))
    end
    
    %Quantization
    sizeResult = size(compand_result,2);
    maxBits = 1024;
    data = zeros(2^levels,sizeResult);
    dataS = zeros(2^levels,sizeResult);
    
    for i = 1:2^levels        
        Max = max(compand_result(i,:));
        Min = min(compand_result(i,:));

        for j = 1:sizeResult
            s = 0;
            data_coded = 0;
            if (compand_result(i,j) < 0)
                s = 1;
                data_coded = compand_result(i,j)*maxBits/Min;
            else
                data_coded = compand_result(i,j)*maxBits/Max;
            end
            data(i,j) = round(data_coded);
            dataS(i,j) = s;
        end
    end

    %--------------------------------------------------------------------------
    %Save bands and parameteres to binary file
    %--------------------------------------------------------------------------

    %
    % Decoding Job (Move to decoder.m when dev is done)
    %

    %Read bands and paramaters from binary file

    %Dequantize (pending)
    for i = 1:2^levels        
        for j = 1:sizeResult
            s = 1;
            if dataS(i,j) == 1
                s = -1;
            end
            compand_result(i,j) = s*data(i,j);
        end
    end

    %Reverse compansion
    for i = 1:2^levels
        compand_mag(i) = max(compand_result(i,:));
        split_result(i,:) = compand(compand_result(i,:), compand_factor, compand_mag(i), 'mu/expander');
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
    % 16 bit per sample, at 44100 Hz, in stereo
    audiowrite(audio_output_filename, join_result, sampleFrequency);
end
