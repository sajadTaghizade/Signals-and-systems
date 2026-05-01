function decoded_message = decoding_amp(received_signal, bit_rate, Mapset)
 
    fs = 100;
    dt = 1/fs;
    samples_per_sec = fs;
    t_sec = 0:dt:(1-dt);
    
    corr_signal = 2 * sin(2*pi*t_sec); 

    num_levels = 2^bit_rate;
    levels = linspace(0, 1, num_levels);
    
    thresholds = (levels(1:end-1) + levels(2:end)) / 2;

    bitstream = '';
    num_seconds = length(received_signal) / samples_per_sec;

    for i = 1:num_seconds
        start_idx = (i-1) * samples_per_sec + 1;
        end_idx = i * samples_per_sec;
        signal_chunk = received_signal(start_idx:end_idx);
        
        corr_val = sum(signal_chunk .* corr_signal) * dt;
        
        level_index = sum(corr_val > thresholds) + 1;
        
        decimal_val = level_index - 1;
        
        bits = dec2bin(decimal_val, bit_rate);
        bitstream = [bitstream, bits];
    end

    decoded_message = "";
    
    for i = 1:5:length(bitstream)
        five_bits = bitstream(i : i+4);
        char = find_char_by_bits(five_bits, Mapset);
        decoded_message = decoded_message + char;
    end
end

function char = find_char_by_bits(bits, Mapset)
    for j = 1:size(Mapset, 2)
        if strcmp(Mapset{2, j}, bits)
            char = Mapset{1, j};
            return;
        end
    end
    char = '?';
end