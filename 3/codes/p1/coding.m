clc; clear; close all;

disp('--- Running Part 1: Frequency Analysis ---');

fs1 = 50; 
t_start1 = -1;
t_end1 = 1;
ts1 = 1/fs1;
t1 = t_start1 : ts1 : t_end1 - ts1; 
N1 = length(t1);

x1 = cos(10 * pi * t1);

y1 = fftshift(fft(x1));
y1_norm = y1 / max(abs(y1));

f1 = (-fs1/2) : (fs1/N1) : (fs1/2 - fs1/N1);

figure('Name', 'Exercise 1-1');
subplot(2,1,1);
stem(t1, x1, 'filled'); title('x1(t) in Time Domain'); xlabel('Time (s)'); grid on;
subplot(2,1,2);
stem(f1, abs(y1_norm), 'filled'); title('|X1(f)| Magnitude'); xlabel('Frequency (Hz)'); grid on;


fs2 = 100; 
t_start2 = 0;
t_end2 = 1;
ts2 = 1/fs2;
t2 = t_start2 : ts2 : t_end2 - ts2;
N2 = length(t2);

x2 = cos(30 * pi * t2 + pi/4);

y2 = fftshift(fft(x2));
y2_norm = y2 / max(abs(y2));
f2 = (-fs2/2) : (fs2/N2) : (fs2/2 - fs2/N2);

tol = 1e-6;
y2_clean = y2;
y2_clean(abs(y2) < tol) = 0;
theta = angle(y2_clean);

figure('Name', 'Exercise 1-2');
subplot(3,1,1);
plot(t2, x2); title('x2(t) in Time Domain'); xlabel('Time (s)'); grid on;
subplot(3,1,2);
stem(f2, abs(y2_norm), 'filled'); title('|X2(f)| Magnitude'); xlabel('Frequency (Hz)'); grid on;
subplot(3,1,3);
plot(f2, theta/pi); title('Phase of X2(f) (Normalized by \pi)');
xlabel('Frequency (Hz)'); ylabel('Phase / \pi'); grid on;


disp(' ');
disp('--- Running Part 2: FSK Modulation & Noise Analysis ---');

chars = ['abcdefghijklmnopqrstuvwxyz .,!;' char(39) '"']; 
if length(chars) ~= 32
    error('تعداد کاراکترها ۳۲ عدد نیست!');
end

MapSet = cell(2, 32);
for i = 1:32
    MapSet{1, i} = chars(i);
    MapSet{2, i} = dec2bin(i-1, 5); 
end
disp('MapSet created successfully.');

message = 'signal';
fs_comm = 100;

bit_rate_1 = 1;
[coded_sig_1, t_total_1] = coding_freq(message, bit_rate_1, MapSet, fs_comm);

bit_rate_5 = 5;
[coded_sig_5, t_total_5] = coding_freq(message, bit_rate_5, MapSet, fs_comm);

figure('Name', 'Exercise 2-3: Coded Signals');
subplot(2,1,1);
plot(t_total_1, coded_sig_1); title(['Coded Signal: "', message, '" (Bit Rate = 1 bps)']);
xlabel('Time (s)'); xlim([0, 20]); 
subplot(2,1,2);
plot(t_total_5, coded_sig_5); title(['Coded Signal: "', message, '" (Bit Rate = 5 bps)']);
xlabel('Time (s)'); 

decoded_msg_1 = decoding_freq(coded_sig_1, bit_rate_1, MapSet, fs_comm);
decoded_msg_5 = decoding_freq(coded_sig_5, bit_rate_5, MapSet, fs_comm);

disp(['Decoded Message (1 bps): ', decoded_msg_1]);
disp(['Decoded Message (5 bps): ', decoded_msg_5]);

var_noise = 0.0001;
noise_1 = sqrt(var_noise) * randn(size(coded_sig_1));
noise_5 = sqrt(var_noise) * randn(size(coded_sig_5));

noisy_sig_1 = coded_sig_1 + noise_1;
noisy_sig_5 = coded_sig_5 + noise_5;

decoded_noisy_1 = decoding_freq(noisy_sig_1, bit_rate_1, MapSet, fs_comm);
decoded_noisy_5 = decoding_freq(noisy_sig_5, bit_rate_5, MapSet, fs_comm);

disp('--- Noise Analysis (Variance = 0.0001) ---');
disp(['Decoded Noisy (1 bps): ', decoded_noisy_1]);
disp(['Decoded Noisy (5 bps): ', decoded_noisy_5]);

disp('--- Increasing Noise Power ---');
variances = [0.001, 0.01, 0.05, 0.1, 0.5, 1, 2, 5];

for v = variances
    n1 = sqrt(v) * randn(size(coded_sig_1));
    n5 = sqrt(v) * randn(size(coded_sig_5));
    
    dec_1 = decoding_freq(coded_sig_1 + n1, bit_rate_1, MapSet, fs_comm);
    dec_5 = decoding_freq(coded_sig_5 + n5, bit_rate_5, MapSet, fs_comm);
    
    is_correct_1 = strcmp(dec_1, message);
    is_correct_5 = strcmp(dec_5, message);
    
    if ~is_correct_5 && exist('fail_v5', 'var') == 0
        fail_v5 = v; 
    end
     if ~is_correct_1 && exist('fail_v1', 'var') == 0
        fail_v1 = v; 
    end
end

if exist('fail_v5', 'var')
    fprintf('Bit Rate 5 failed around Variance: %.3f\n', fail_v5);
else
    fprintf('Bit Rate 5 survived all test variances.\n');
end

if exist('fail_v1', 'var')
    fprintf('Bit Rate 1 failed around Variance: %.3f\n', fail_v1);
else
    fprintf('Bit Rate 1 survived all test variances.\n');
end
disp('Conclusion: Lower bit rate (wider freq spacing) is more robust to noise.');




function [coded_signal, time_vector] = coding_freq(message, bit_rate, MapSet, fs)
    full_bits = '';
    for k = 1:length(message)
        char_idx = find(strcmp(MapSet(1, :), message(k)));
        if isempty(char_idx)
            error(['Character not found in MapSet: ', message(k)]);
        end
        full_bits = [full_bits, MapSet{2, char_idx}];
    end
    
    T_symbol = 1;
    N_samples = T_symbol * fs;
    num_bits_total = length(full_bits);
    
    if mod(num_bits_total, bit_rate) ~= 0
        padding = bit_rate - mod(num_bits_total, bit_rate);
        full_bits = [full_bits, repmat('0', 1, padding)];
    end
    
    num_symbols = length(full_bits) / bit_rate;
    coded_signal = [];
    
    possible_values = 2^bit_rate;
    freq_map = round(linspace(5, 45, possible_values)); 
    
    t_local = 0 : 1/fs : T_symbol - 1/fs;
    
    for i = 1:num_symbols
        bits_chunk = full_bits((i-1)*bit_rate + 1 : i*bit_rate);
        dec_val = bin2dec(bits_chunk);
        
        target_freq = freq_map(dec_val + 1); 
        
        sig_chunk = sin(2 * pi * target_freq * t_local);
        coded_signal = [coded_signal, sig_chunk];
    end
    
    time_vector = (0:length(coded_signal)-1) / fs;
end

function decoded_message = decoding_freq(received_signal, bit_rate, MapSet, fs)
    T_symbol = 1;
    N_samples = T_symbol * fs;
    total_samples = length(received_signal);
    num_symbols = floor(total_samples / N_samples);
    
    possible_values = 2^bit_rate;
    freq_map = round(linspace(5, 45, possible_values));
    
    extracted_bits = '';
    
    f_axis = (-fs/2) : (fs/N_samples) : (fs/2 - fs/N_samples);
    
    for i = 1:num_symbols
        chunk = received_signal((i-1)*N_samples + 1 : i*N_samples);
        
        Y = fftshift(fft(chunk));
        [~, max_idx] = max(abs(Y)); 
        dominant_freq = abs(f_axis(max_idx)); 
        
        [~, min_diff_idx] = min(abs(freq_map - dominant_freq));
        detected_val = min_diff_idx - 1;
        
        bits_chunk = dec2bin(detected_val, bit_rate);
        extracted_bits = [extracted_bits, bits_chunk];
    end
    
    decoded_message = '';
    for k = 1:5:length(extracted_bits)
        if k+4 <= length(extracted_bits)
            five_bits = extracted_bits(k : k+4);
            for m = 1:32
                if strcmp(MapSet{2, m}, five_bits)
                    decoded_message = [decoded_message, MapSet{1, m}];
                    break;
                end
            end
        end
    end
end