function plate_box = find_plate_bluestrip(image, template)
    % Finds the license plate using cross-correlation with the blue strip template.
    
    % Resize image for consistent matching
    image_resized = imresize(image, [480, NaN]);
    
    % Perform cross-correlation on each color channel
    corr_r = normxcorr2(template(:,:,1), image_resized(:,:,1));
    corr_g = normxcorr2(template(:,:,2), image_resized(:,:,2));
    corr_b = normxcorr2(template(:,:,3), image_resized(:,:,3));
    
    % Average the correlations
    corr_avg = (corr_r + corr_g + corr_b) / 3;
    
    % Find the peak correlation
    [~, max_idx] = max(corr_avg(:));
    [y_peak, x_peak] = ind2sub(size(corr_avg), max_idx);
    
    % Calculate the bounding box based on peak position and standard plate ratios
    corr_offset_y = y_peak - size(template, 1);
    corr_offset_x = x_peak - size(template, 2);
    
    % Standard ratio of bluestrip width to full plate width is ~1/11
    plate_width = size(template, 2) * 11;
    plate_height = size(template, 1) * 1.5; % Estimate
    
    % Scale back to original image size
    scale = size(image, 2) / size(image_resized, 2);
    plate_box = [corr_offset_x*scale, corr_offset_y*scale, plate_width*scale, plate_height*scale];
    
    % Check if the found box is reasonable
    if plate_box(3) < 100 || plate_box(4) < 20
        plate_box = []; % Invalid box
    end
end