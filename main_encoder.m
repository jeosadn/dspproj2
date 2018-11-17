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
levels = 3;
N = 60*levels;
mul = 10;
fmuestreo = mul*2^levels;
tmax = 2^levels*N;


tvecmues = 0:1/fmuestreo:tmax-(1/fmuestreo);
smues = zeros(1, length(tvecmues));
for i = 1:fmuestreo/2-1
    if mod(i, mul/2) ~= 0
        smues = smues + i*cos(2*pi*i.*tvecmues);
    end
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
stem(0:(fmuestreo-1), abs(fft(join_result(N*2^levels+1:end), fmuestreo)));
title(sprintf('Espectro de bandas unidas'));
