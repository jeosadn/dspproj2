function encoder(audio_input_filename, audio_output_filename)
    %--------------------------------------------------------------------------
    % Read audio File
    %--------------------------------------------------------------------------
    %Input characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    [sampleData, sampleFrequency] = audioread(audio_input_filename);

    %Split in bands
    split_result = band_split(sampleData.', 60, 2);

    %Rejoin bands
    join_result = band_join(split_result, 60);

    %--------------------------------------------------------------------------
    % Write audio file
    %--------------------------------------------------------------------------
    %Output characteristics:
    % 16 bit per sample, at 44100 Hz, in stereo
    audiowrite(audio_output_filename, join_result, sampleFrequency);
end
