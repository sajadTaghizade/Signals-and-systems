% =========================================================================
%      Final Script for Character Recognition (Based on Report)
%                           File: p2_final.m
% =========================================================================

%% Initialization
clear;
clc;
close all;

%% Load Dataset and Image
load('Farsi_DATA_TABLE.mat');
[fileName, filePath] = uigetfile({'*.jpg';'*.png'}, 'Select a CROPPED Plate Image');
if fileName == 0, disp('User cancelled.'); return; end
plate_image = imread(fullfile(filePath, fileName));
figure; imshow(plate_image); title('Input Plate Image');

%% Recognize Characters
[recognized_text, ~] = recognize_plate_characters(plate_image, data_table);

%% Final Output
fprintf('\n========================================\n');
fprintf('Recognized Plate: %s\n', recognized_text);
fprintf('========================================\n');

file_id = fopen('license_plate.txt', 'w', 'n', 'UTF-8');
fprintf(file_id, '%s\n', recognized_text);
fclose(file_id);
fprintf('Result saved to license_plate.txt\n');