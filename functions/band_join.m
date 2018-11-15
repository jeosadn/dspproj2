function result = band_join(band_list)
    %Data length check
    while mod(log2(size(band_list, 1)), 1) ~= 0
        band_list = [band_list; zeros(1, size(band_list, 2))]; %#ok<AGROW>
    end

    %Recursive processing
    if size(band_list, 1) == 1
        result = band_list;
    else
        low_band = band_join(band_list(1:end/2,:));
        high_band = band_join(band_list(end/2+1:end,:));
        result = [low_band high_band];
    end
