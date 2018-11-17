function result = band_split(original_signal, N, levels)
    if levels == 0;
        result = original_signal;
    else
        low_filter = fir1(N, 1/2);
        low_band = filter(low_filter, 1, original_signal);
        low_band = low_band(1:2:end);
        low_band = low_band .* 2;
        low_band = band_split(low_band, N, levels-1);

        high_filter = fir1(N, 1/2, 'high');
        high_band = filter(high_filter, 1, original_signal);
        high_band = high_band(1:2:end);
        high_band(2:2:end) = high_band(2:2:end) .* -1;
        high_band = high_band .* 2;
        high_band = band_split(high_band, N, levels-1);

        result = [low_band; high_band];
    end
