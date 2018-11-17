clc;
clear;
close all;

addpath('functions');
%pkg load communications

%PARSING Parameters
audio_input_filename = read_parameters('parameters.txt','audio_input_filename');
audio_output_filename = read_parameters('parameters.txt','audio_output_filename');
fprintf('Encoder parsed parameters\n');

%CODER
fprintf('Starting encode.\n');
tic;
encoder(char(audio_input_filename), char(audio_output_filename));
fprintf('Coding time:\n');
toc;

%
%Band splitter
%

%Create sample input
levels = 2;
fmuestreo = 44*levels;
tmax = 10;
N = 60;

fsenal = [1 2 3  14 15 16  25 26 27  36 37 38];
asenal = [1 3 5   7 11  9  17 15 13  21 19 23];

tvecmues = 0:1/fmuestreo:tmax-(1/fmuestreo);
smues = zeros(1, length(tvecmues));
for i = 1:length(fsenal)
    smues = smues + asenal(i)*cos(2*pi*fsenal(i).*tvecmues);
end

%Plot sample input
figure();
stem(0:(fmuestreo-1), abs(fft(smues, fmuestreo)));
title(sprintf('Espectro señal muestreada a %d Hz', fmuestreo));

%Split in bands
split_result = band_split(smues, N, levels);

%Plot split bands
for i = 1:size(split_result, 1)
    figure();
    stem(0:((fmuestreo/2^levels)-1), abs(fft(split_result(i,N+1:end), (fmuestreo/2^levels))));
    title(sprintf('Espectro de banda %d', i))
end

join_result = band_join(split_result, N);

%Plot joined bands
figure();
stem(0:(fmuestreo-1), abs(fft(join_result(N*2+1:end), fmuestreo)));
title(sprintf('Espectro de bandas unidas'));

return;
%
% Debugging join_result. high_band and low_band are OK, the problem is
% joining them together
%

figure(); %#ok<UNRCH>
stem(0:((fmuestreo/2^levels)-1), abs(fft(split_result(1,N+1:end), (fmuestreo/2^levels))));
title(sprintf('Espectro de banda %d', 1))


low_filter = fir1(N, 1/2);
low_band = upsample(split_result(1,:), 2);
low_band = filter(low_filter, 1, low_band);

figure();
stem(0:(fmuestreo/2-1), abs(fft(low_band(N*2+1:end), fmuestreo/2)));
title(sprintf('Espectro banda 1 upsampled'));

figure();
stem(0:((fmuestreo/2^levels)-1), abs(fft(split_result(2,N+1:end), (fmuestreo/2^levels))));
title(sprintf('Espectro de banda %d', 2))

high_filter = fir1(N, 1/2, 'high');
high_band = upsample(split_result(2,:), 2);
high_band = filter(high_filter, 1, high_band);
high_band(2:2:end) = high_band(2:2:end) .* -1;

figure();
stem(0:(fmuestreo/2-1), abs(fft(high_band(N*2+1:end), fmuestreo/2)));
title(sprintf('Espectro banda 2 upsampled'));

low_low_band = high_band + low_band;

figure();
stem(0:(fmuestreo/2-1), abs(fft(low_low_band(N*2+1:end), fmuestreo/2)));
title(sprintf('Espectro señal upsampled a %d Hz', fmuestreo/2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure();
% stem(0:((fmuestreo/2^levels)-1), abs(fft(split_result(3,N+1:end), (fmuestreo/2^levels))));
% title(sprintf('Espectro de banda %d', 3))


low_filter = fir1(N, 1/2);
low_band = upsample(split_result(3,:), 2);
low_band = filter(low_filter, 1, low_band);

% figure();
% stem(0:(fmuestreo/2-1), abs(fft(low_band(N*2+1:end), fmuestreo/2)));
% title(sprintf('Espectro banda 3 upsampled'));
% 
% figure();
% stem(0:((fmuestreo/2^levels)-1), abs(fft(split_result(4,N+1:end), (fmuestreo/2^levels))));
% title(sprintf('Espectro de banda %d', 4))

high_filter = fir1(N, 1/2, 'high');
high_band = upsample(split_result(4,:), 2);
high_band = filter(high_filter, 1, high_band);
high_band(2:2:end) = high_band(2:2:end) .* -1;

figure();
stem(0:(fmuestreo/2-1), abs(fft(high_band(N*2+1:end), fmuestreo/2)));
title(sprintf('Espectro banda 4 upsampled'));

high_high_band = high_band + low_band;

figure();
stem(0:(fmuestreo/2-1), abs(fft(high_high_band(N*2+1:end), fmuestreo/2)));
title(sprintf('Espectro señal upsampled a %d Hz', fmuestreo/2));

%%%%
low_filter = fir1(N, 1/2);
low_band = upsample(low_low_band, 2);
low_band = filter(low_filter, 1, low_band);

high_filter = fir1(N, 1/2, 'high');
high_band = upsample(high_high_band, 2);
high_band = filter(high_filter, 1, high_band);
high_band(2:2:end) = high_band(2:2:end) .* -1;

result = low_band + high_band;

figure();
stem(0:(fmuestreo-1), abs(fft(result(N*2+1:end), fmuestreo)));
title(sprintf('Espectro señal upsampled a %d Hz', fmuestreo));