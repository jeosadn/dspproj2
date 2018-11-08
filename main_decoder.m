addpath('functions');
%pkg load communications

%PARSING Parameters
audio_input_filename = read_parameters('parameters.txt','audio_input_filename');
audio_output_filename = read_parameters('parameters.txt','audio_output_filename');
fprintf('Decoder parsed parameters\n');

%DECODER
fprintf('Starting decode.\n');
tic;
decoder(char(audio_output_filename));
fprintf('Decoding time:\n');
toc;
