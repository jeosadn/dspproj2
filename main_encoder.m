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
