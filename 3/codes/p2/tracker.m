

clear; clc; close all;

[fileName, pathName] = uigetfile({'*.mp4';'*.avi';'*.mov';'*.mkv'}, 'Select the IR video file');
if isequal(fileName, 0)
    disp('User canceled the selection.');
    return;
end
videoPath = fullfile(pathName, fileName);
disp(['Loading video: ', videoPath]);

try
    videoReader = VideoReader(videoPath);
catch
    error('Cannot read video file. Make sure you have the correct codecs.');
end

videoPlayer = vision.VideoPlayer('Name', 'Motion Tracker');
MOTION_THRESHOLD = 15; 
MIN_MOTION_AREA = 5; 

se_noise = strel('rectangle', [3 3]); 
se_group = strel('rectangle', [15 15]);


previousFrame = readFrame(videoReader);
if size(previousFrame, 3) == 3
    previousFrameGray = rgb2gray(previousFrame);
else
    previousFrameGray = previousFrame;
end


while hasFrame(videoReader)
    currentFrame = readFrame(videoReader);
    
    if size(currentFrame, 3) == 3
        currentFrameGray = rgb2gray(currentFrame);
    else
        currentFrameGray = currentFrame;
    end
    
    diffImage = abs(currentFrameGray - previousFrameGray);
    
    motionMask = diffImage > MOTION_THRESHOLD;
    
    cleanedMask = imopen(motionMask, se_noise);
    cleanedMask = imclose(cleanedMask, se_group);
    
    cc = bwconncomp(cleanedMask);
    
    bbox = []; 
    
    if cc.NumObjects > 0
        stats = regionprops(cc, 'Area', 'BoundingBox');
        
        [maxArea, maxIndex] = max([stats.Area]);
        
        if maxArea > MIN_MOTION_AREA
            bbox = stats(maxIndex).BoundingBox;
        end
    end
    
    outputFrame = currentFrame;
    
    if ~isempty(bbox)
        outputFrame = insertShape(outputFrame, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 3);
    end
    
    step(videoPlayer, outputFrame);
    
    previousFrameGray = currentFrameGray;
end

disp('Tracking finished.');
release(videoPlayer);