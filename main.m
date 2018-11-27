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
encoder(char(audio_input_filename), 256);
fprintf('Coding time:\n');
toc;

%DECODER
fprintf('Starting decode.\n');
tic;
decoder(char(audio_output_filename), 256);
fprintf('Coding time:\n');
toc;