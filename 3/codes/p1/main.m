
clear; clc; close all;

%% 1
Mapset = createMapset();


blockSize = 5;      
threshold = 100;   


original_image = imread('cameraman.tif');
if ~isa(original_image, 'uint8')
    original_image = im2uint8(original_image);
end
if size(original_image, 3) == 3
    original_image = rgb2gray(original_image);
end

%% 2
message = 'signal';

%% 3
fprintf('Encoding message "signal"\n');
try
    encoded_image = coding(message, original_image, Mapset, blockSize, threshold);
    
    figure;
    subplot(1, 2, 1);
    imshow(original_image);
    title('Original Image');
    
    subplot(1, 2, 2);
    imshow(encoded_image);
    title('Encoded Image with "signal"');
    
    disp('Plotted original vs encoded image.');

catch ME
    fprintf('Error encoding: %s\n', ME.message);
end


%% 4

if exist('encoded_image', 'var')
    fprintf('Decoding image...\n');
    decoded_message = decoding(encoded_image, Mapset, blockSize, threshold);
    
    if strcmp(message, decoded_message)
        disp('Success');
    else
        disp('Failure');
    end
end