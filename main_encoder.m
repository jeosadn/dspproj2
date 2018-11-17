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

% figure();
% stem(0:((fmuestreo/2^levels)-1), abs(fft(split_result(1,N+1:end), (fmuestreo/2^levels))));
% title(sprintf('Espectro de banda %d', 1))
%
%
% low_filter = fir1(N, 1/2);
% low_band = zeros(1, 2*size(split_result,2));
% low_band(1:2:end) = split_result(1,:);
% low_band = filter(low_filter, 1, low_band);
%
% figure();
% stem(0:(fmuestreo/2-1), abs(fft(low_band, fmuestreo/2)));
% title(sprintf('Espectro señal muestreada a %d Hz', fmuestreo/2));
