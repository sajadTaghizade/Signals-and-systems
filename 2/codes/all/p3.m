% =========================================================================
%      Final Script for Plate Localization (Based on Report)
%                           File: p3_final.m
% =========================================================================

%% Initialization
clear;
clc;
close all;

%% Load Dataset and Image
% Load the character dataset created by training_loading_Farsi.m
load('Farsi_DATA_TABLE.mat');

% Get the car image from the user
[fileName, filePath] = uigetfile({'*.jpg';'*.png'}, 'Select a Car Image');
if fileName == 0, disp('User cancelled.'); return; end
original_image = imread(fullfile(filePath, fileName));
figure; imshow(original_image); title('Original Image');

%% Step 1: Plate Localization using Bluestrip Method (Primary)
% As per the report, this is the most accurate method.
fprintf('Attempting to find plate using Bluestrip method...\n');
bluestrip_template = imread('bluestrip_template.png');
plate_box = find_plate_bluestrip(original_image, bluestrip_template);

%% Step 2: Fallback to Color Changes Method
% If the bluestrip method fails, use the color changes method.
if isempty(plate_box)
    fprintf('Bluestrip method failed. Falling back to Color Changes method...\n');
    candidate_boxes = find_plate_colorchanges(original_image);
else
    candidate_boxes = {plate_box}; % Put the single result in a cell for consistency
end

%% Step 3: Recognize Characters in All Candidate Regions
if isempty(candidate_boxes)
    fprintf('Sorry, no valid license plate was automatically detected.\n');
    return;
end

best_recognition_text = '';
max_recognized_chars = 0;
best_plate_image = [];

fprintf('Found %d candidate regions. Analyzing each one...\n', length(candidate_boxes));

% Loop through all found regions and choose the one with the most recognized characters.
for i = 1:length(candidate_boxes)
    current_box = candidate_boxes{i};
    plate_image = imcrop(original_image, current_box);
    
    % Call the main recognition function
    [recognized_text, num_chars] = recognize_plate_characters(plate_image, data_table);
    
    fprintf('Candidate %d -> Recognized: %s (%d chars)\n', i, recognized_text, num_chars);
    
    if num_chars > max_recognized_chars
        max_recognized_chars = num_chars;
        best_recognition_text = recognized_text;
        best_plate_image = plate_image;
    end
end

%% Final Output
if ~isempty(best_recognition_text)
    figure; imshow(best_plate_image); title(['Best Match: ', best_recognition_text]);
    fprintf('\n========================================\n');
    fprintf('Final Recognized Plate: %s\n', best_recognition_text);
    fprintf('========================================\n');
    
    % Save to text file
    file_id = fopen('license_plate.txt', 'w', 'n', 'UTF-8');
    fprintf(file_id, '%s\n', best_recognition_text);
    fclose(file_id);
    fprintf('Result saved to license_plate.txt\n');
else
    fprintf('Could not recognize characters in any of the found regions.\n');
end