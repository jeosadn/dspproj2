function result = band_join(band_list, N)
    if size(band_list, 1) == 1
        result = band_list;
    else
        low_filter = fir1(N, 1/2);
        low_band = band_join(band_list(1:end/2,:), N);
        low_band = upsample(low_band, 2);
        low_band = filter(low_filter, 1, low_band);

        high_filter = fir1(N, 1/2, 'high');
        high_band = band_join(band_list(end/2+1:end,:), N);
        high_band(2:2:end) = high_band(2:2:end) .* -1;
        high_band = upsample(high_band, 2);
        high_band = filter(high_filter, 1, high_band);

        result = low_band + high_band;
    end
