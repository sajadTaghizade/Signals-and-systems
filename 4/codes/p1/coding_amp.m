function [coded_signal, time_vector] = coding_amp(message, bit_rate, Mapset)
    
    fs = 100;
    dt = 1/fs;
    t_sec = 0:dt:(1-dt);
    
    base_signal = sin(2*pi*t_sec); 
    zero_signal = zeros(size(t_sec));

    bitstream = '';
    message_str = char(message);
    
    for k = 1:length(message_str)
        currentChar = message_str(k);
        found = false;
        for j = 1:size(Mapset, 2)
            if strcmp(Mapset{1, j}, currentChar)
                bitstream = [bitstream, Mapset{2, j}];
                found = true;
                break;
            end
        end
        if ~found
            warning('کاراکتر %c در Mapset یافت نشد.', currentChar);
        end
    end
    
    coded_signal = [];
    
    num_levels = 2^bit_rate;
    amplitudes = linspace(0, 1, num_levels);
    
    for i = 1:bit_rate:length(bitstream)
        bit_chunk = bitstream(i : i + bit_rate - 1);
        
        decimal_val = bin2dec(bit_chunk);
        
        amplitude = amplitudes(decimal_val + 1);
        
        if amplitude == 0
            signal_chunk = zero_signal;
        else
            signal_chunk = amplitude * base_signal;
        end
        
        coded_signal = [coded_signal, signal_chunk];
    end
    
    total_samples = length(coded_signal);
    time_vector = (0:total_samples-1) * dt;
end