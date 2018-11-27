clc;
clear;
close all;

addpath('functions');
%pkg load communications

numBits = zeros(1,4);

%PARSING Parameters
audio_input_filename = read_parameters('parameters.txt','audio_input_filename');
audio_output_filename = read_parameters('parameters.txt','audio_output_filename');
numBits(1,1) = str2num(read_parameters('parameters.txt','num_bits_w1'));
numBits(1,2) = str2num(read_parameters('parameters.txt','num_bits_w2'));
numBits(1,3) = str2num(read_parameters('parameters.txt','num_bits_w3'));
numBits(1,4) = str2num(read_parameters('parameters.txt','num_bits_w4'));
numBitsMax = str2num(read_parameters('parameters.txt','num_bits_max'));
fprintf('Encoder parsed parameters\n');

%CODER
fprintf('Starting encode.\n');
tic;
encoder(char(audio_input_filename), 256, numBits, numBitsMax);
fprintf('Coding time:\n');
toc;