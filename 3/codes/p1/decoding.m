function decoded_message = decoding(encoded_image, Mapset, blockSize, threshold)
    
    [rows, cols] = size(encoded_image);
    suitable_pixel_indices = [];
    
    for r = 1:blockSize:rows-blockSize+1
        for c = 1:blockSize:cols-blockSize+1
     
            block = encoded_image(r:r+blockSize-1, c:c+blockSize-1);
            
            if var(double(block(:))) > threshold
                [C_idx, R_idx] = meshgrid(c:c+blockSize-1, r:r+blockSize-1);
                linear_indices = sub2ind(size(encoded_image), R_idx(:), C_idx(:));
                suitable_pixel_indices = [suitable_pixel_indices; linear_indices];
            end
        end
    end
    binary_string = '';
    
    for k = 1:length(suitable_pixel_indices)
        
        pixel_idx = suitable_pixel_indices(k);
        pixel_value = encoded_image(pixel_idx);
        
        lsb = bitget(pixel_value, 1);
        
        binary_string = [binary_string, num2str(lsb)];
    end
    
    decoded_message = '';
    
    for k = 1:5:length(binary_string)
        
        if k+4 > length(binary_string)
            break;
        end
        
        five_bits = binary_string(k:k+4);
        
        if strcmp(five_bits, '11111')
            break; 
        end
        
        idx = find(strcmp(Mapset(2, :), five_bits));
        
        if ~isempty(idx)
            decoded_message = [decoded_message, Mapset{1, idx}];
        else
            decoded_message = [decoded_message, '?'];
        end
    end
    
    fprintf('Decoded message: %s\n', decoded_message);
end