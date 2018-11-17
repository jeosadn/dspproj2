function encoder(audio_input_filename, audio_output_filename, N)
    %N is the # of filter coefficients
    %Variables that must be handled
    levels = 2; %This can be dynamic
    compand_factor = [5 3 2 6]; %This is a parameter for the encoder, saved in file for decoder
    compand_mag = [10 15 20 25]; %This is a parameter for the encoder, saved in file for decoder
    %--------------------------------------------------------------------------
    % Read audio File
    %--------------------------------------------------------------------------
    %Input characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    [sampleData, sampleFrequency] = audioread(audio_input_filename);

    %
    % Encoding Job
    %
    %Split in bands
    split_result = band_split(sampleData.', N, levels);

    %Compand each band
    for i = 1:2^levels
        split_result(i,:) = compand(split_result(i,:), compand_factor(i), compand_mag(i));
    end

    %Quantization (pending)
    %Fill here!

    %Save bands and parameteres to binary file
    %Fill here

    %
    % Decoding Job (Move to decoder.m when dev is done)
    %

    %Read bands and paramaters from binary file

    %Dequantize (pending)
    %Fill here

    %Reverse compansion
    for i = 1:2^levels
        split_result(i,:) = compand(split_result(i,:), compand_factor(i), compand_mag(i), 'mu/expander');
    end

    %Rejoin bands
    join_result = band_join(split_result, N);

    %--------------------------------------------------------------------------
    % Write audio file
    %--------------------------------------------------------------------------
    %Output characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    audiowrite(audio_output_filename, join_result, sampleFrequency);
end
