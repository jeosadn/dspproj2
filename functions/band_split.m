function result = band_split(original_signal, levels)
    %Data length check
    while mod(log2(length(original_signal)), 1) ~= 0
        original_signal = [original_signal 0]; %#ok<AGROW>
    end

    %Band number check
    if length(original_signal) < 2^levels
        fprintf('Error: Not enough data for that amount of levels\n');
        result = [];
        return
    end

    %Recursive processing
    if levels == 0;
        result = original_signal;
    else
        low_band = band_split(original_signal(1:end/2), levels-1);
        high_band = band_split(original_signal(end/2+1:end), levels-1);
        result = [low_band; high_band];
    end
