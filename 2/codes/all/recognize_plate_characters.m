function [final_output, num_recognized] = recognize_plate_characters(plate_image, data_table)
    % This function implements the character recognition pipeline described in the report.

    % Constants from the report (can be tuned)
    SMALL_OBJECT_AREA = 50;
    BACKGROUND_AREA = 1500;
    LONG_ASPECT = 4;
    SEGMENT_THRESHOLD = 0.45;

    % 1. Pre-processing
    gray_plate = rgb2gray(plate_image);
    threshold = graythresh(gray_plate);
    binary_plate = ~imbinarize(gray_plate, threshold - 0.1);

    % 2. Remove small objects and background
    binary_plate = bwareaopen(binary_plate, SMALL_OBJECT_AREA);
    binary_plate = binary_plate - bwareaopen(binary_plate, BACKGROUND_AREA);
    
    % 3. Segmentation and Geometric Filtering
    [L, Ne] = bwlabel(binary_plate);
    props = regionprops(L, 'BoundingBox', 'Area');
    
    valid_indices = [];
    for i = 1:Ne
        bbox = props(i).BoundingBox;
        aspect_ratio = bbox(3) / bbox(4); % width / height
        if (aspect_ratio < LONG_ASPECT) && (1/aspect_ratio < LONG_ASPECT)
            valid_indices = [valid_indices, i];
        end
    end
    binary_plate = ismember(L, valid_indices);
    [L, Ne] = bwlabel(binary_plate);
    props = regionprops(L, 'BoundingBox', 'Area');
    
    % Sort objects by position
    all_bboxes = cat(1, props.BoundingBox);
    [~, sorted_indices] = sort(all_bboxes(:, 1));
    
    % 4. Dot Merging and Recognition
    final_output = '';
    i = 1;
    while i <= Ne
        current_idx = sorted_indices(i);
        bbox1 = props(current_idx).BoundingBox;
        
        % Check for dot merging
        if i < Ne
            next_idx = sorted_indices(i+1);
            bbox2 = props(next_idx).BoundingBox;
            
            % If the next object is small (a dot) and is horizontally within the current object
            if props(next_idx).Area < SMALL_OBJECT_AREA * 2 && ...
               (bbox2(1) > bbox1(1) && (bbox2(1)+bbox2(3)) < (bbox1(1)+bbox1(3)))
           
                % Merge bounding boxes
                merged_x = min(bbox1(1), bbox2(1));
                merged_y = min(bbox1(2), bbox2(2));
                merged_w = max(bbox1(1)+bbox1(3), bbox2(1)+bbox2(3)) - merged_x;
                merged_h = max(bbox1(2)+bbox1(4), bbox2(2)+bbox2(4)) - merged_y;
                
                Y = imcrop(binary_plate, [merged_x, merged_y, merged_w, merged_h]);
                i = i + 2; % Skip the next object as it has been merged
            else
                Y = imcrop(binary_plate, bbox1);
                i = i + 1;
            end
        else
            Y = imcrop(binary_plate, bbox1);
            i = i + 1;
        end
        
        % Correlation
        ro = zeros(1, size(data_table, 2));
        for k = 1:size(data_table, 2)
            template = data_table{1,k};
            Y_resized = imresize(Y, size(template));
            ro(k) = corr2(template, Y_resized);
        end
        
        [max_ro, pos] = max(ro);
        if max_ro > SEGMENT_THRESHOLD
            out = cell2mat(data_table(2,pos));
            final_output = [final_output, out];
        end
    end
    num_recognized = length(final_output);
end