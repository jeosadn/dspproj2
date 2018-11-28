clc;
clear;
close all;

addpath('functions');
pkg load communications

numBits = zeros(1,4);

%PARSING Parameters
audio_input_filename = read_parameters('parameters.txt','audio_input_filename');
audio_output_filename = read_parameters('parameters.txt','audio_output_filename');
configuration = read_parameters('parameters.txt','configuration');
switch configuration
    case 'quality'
        numBits(1,1) = 16;
        numBits(1,2) = 14;
        numBits(1,3) = 8;
        numBits(1,4) = 4;
    case 'balanced'
        numBits(1,1) = 12;
        numBits(1,2) = 8;
        numBits(1,3) = 5;
        numBits(1,4) = 3;
    case 'compression'
        numBits(1,1) = 8;
        numBits(1,2) = 5;
        numBits(1,3) = 3;
        numBits(1,4) = 2;
end

numBitsMax = str2num(read_parameters('parameters.txt','num_bits_max'));
fprintf('Encoder parsed parameters\n');

%CODER
fprintf('Starting encode.\n');
tic;
encoder(char(audio_input_filename), 256, numBits, numBitsMax);
fprintf('Coding time:\n');
toc;