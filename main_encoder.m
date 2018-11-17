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
fmuestreo = 88;
tmax = 10;
N = 60;
div = 2;

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
split_result = band_split(smues, N, 2);

%Plot split bands
for i = 1:size(split_result, 1)
    figure();
    stem(0:(fmuestreo-1), abs(fft(split_result(i,N+1:end), fmuestreo)));
    title(sprintf('Espectro de banda %d', i))
end
