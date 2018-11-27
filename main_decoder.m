clc;
clear;
close all;

addpath('functions');
%pkg load communications

%PARSING Parameters
audio_input_filename = read_parameters('parameters.txt','audio_input_filename');
audio_output_filename = read_parameters('parameters.txt','audio_output_filename');
numBitsMax = str2num(read_parameters('parameters.txt','num_bits_max'));
fprintf('Decoder parsed parameters\n');

%DECODER
fprintf('Starting decode.\n');
tic;
decoder(char(audio_output_filename), 256, numBitsMax);
fprintf('Coding time:\n');
toc;
