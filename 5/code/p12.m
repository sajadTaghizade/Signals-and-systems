clc; clear; close all;

rng(42); 

disp('--- Part 1 ---');

fs1 = 50;
t1 = -1 : 1/fs1 : 1 - 1/fs1;
x1 = cos(10 * pi * t1);
y1 = fftshift(fft(x1));
y1 = y1 / max(abs(y1));
f1 = (-fs1/2) : (fs1/length(t1)) : (fs1/2 - fs1/length(t1));

figure('Name', 'Exercise 1');
subplot(2,1,1); stem(t1, x1, 'filled'); title('x1(t)'); grid on;
subplot(2,1,2); stem(f1, abs(y1), 'filled'); title('|X1(f)|'); grid on;

fs2 = 100;
t2 = 0 : 1/fs2 : 1 - 1/fs2;
x2 = cos(30 * pi * t2 + pi/4);
y2 = fftshift(fft(x2));
y2_norm = y2 / max(abs(y2));
f2 = (-fs2/2) : (fs2/length(t2)) : (fs2/2 - fs2/length(t2));

tol = 1e-6; y2_clean = y2; y2_clean(abs(y2) < tol) = 0;
theta = angle(y2_clean);

figure('Name', 'Exercise 1-2');
subplot(3,1,1); plot(t2, x2); title('x2(t)'); grid on;
subplot(3,1,2); stem(f2, abs(y2_norm), 'filled'); title('|X2(f)|'); grid on;
subplot(3,1,3); plot(f2, theta/pi); title('Phase / \pi'); grid on;

disp(' ');
disp('--- Part 2 ---');

chars = ['abcdefghijklmnopqrstuvwxyz .,!;"'];
MapSet = cell(2, 32);
for i = 1:32
    MapSet{1, i} = chars(i);
    MapSet{2, i} = dec2bin(i-1, 5);
end

message = 'signal';
fs_comm = 100;

freqs_1 = [12, 37]; 
freqs_5 = 5:36; 

bit_rate_1 = 1;
[coded_1, t_1] = coding_freq_custom(message, bit_rate_1, MapSet, fs_comm, freqs_1);

bit_rate_5 = 5;
[coded_5, t_5] = coding_freq_custom(message, bit_rate_5, MapSet, fs_comm, freqs_5);

figure('Name', 'Coded Signals');
subplot(2,1,1); plot(t_1, coded_1); title('1 bps Signal'); xlim([0, 10]);
subplot(2,1,2); plot(t_5, coded_5); title('5 bps Signal');

dec_1 = decoding_bits_custom(coded_1, bit_rate_1, fs_comm, freqs_1);
dec_5 = decoding_bits_custom(coded_5, bit_rate_5, fs_comm, freqs_5);

disp('--- Robustness Test ---');
disp('Running simulation...');

variances = 0.5 : 0.5 : 8.0;

fprintf('%-10s | %-15s | %-15s\n', 'Variance', 'BER (1bps)', 'BER (5bps)');
fprintf('--------------------------------------------------\n');

for v = variances
    err_1 = 0;
    err_5 = 0;
    tot_1 = 0;
    tot_5 = 0;
    
    runs = 200; 
    
    for r = 1:runs
        n1 = sqrt(v) * randn(size(coded_1));
        n5 = sqrt(v) * randn(size(coded_5));
        
        out_1 = decoding_bits_custom(coded_1 + n1, bit_rate_1, fs_comm, freqs_1);
        out_5 = decoding_bits_custom(coded_5 + n5, bit_rate_5, fs_comm, freqs_5);
        
        ref = msg2bits(message, MapSet);
        
        err_1 = err_1 + sum(out_1 ~= ref);
        err_5 = err_5 + sum(out_5 ~= ref);
        
        tot_1 = tot_1 + length(ref);
        tot_5 = tot_5 + length(ref);
    end
    
    ber_1 = err_1 / tot_1;
    ber_5 = err_5 / tot_5;
    
    fprintf('%-10.1f | %-15.4f | %-15.4f\n', v, ber_1, ber_5);
end

function bits = msg2bits(msg, MapSet)
    bits = '';
    for k = 1:length(msg)
        idx = find(strcmp(MapSet(1, :), msg(k)));
        bits = [bits, MapSet{2, idx}];
    end
end

function [coded_signal, time_vector] = coding_freq_custom(message, bit_rate, MapSet, fs, freq_map)
    full_bits = msg2bits(message, MapSet);
    
    while mod(length(full_bits), bit_rate) ~= 0
        full_bits = [full_bits '0'];
    end
    
    num_syms = length(full_bits) / bit_rate;
    t_local = 0 : 1/fs : 1 - 1/fs;
    coded_signal = [];
    
    for i = 1:num_syms
        bits = full_bits((i-1)*bit_rate+1 : i*bit_rate);
        val = bin2dec(bits);
        f_target = freq_map(val + 1);
        coded_signal = [coded_signal, sin(2*pi*f_target*t_local)];
    end
    time_vector = (0:length(coded_signal)-1)/fs;
end

function bits_stream = decoding_bits_custom(received_signal, bit_rate, fs, freq_map)
    N_samp = fs; 
    num_syms = floor(length(received_signal) / N_samp);
    
    bits_stream = '';
    f_axis = (-fs/2) : (fs/N_samp) : (fs/2 - fs/N_samp);
    
    cand_indices = zeros(size(freq_map));
    for k = 1:length(freq_map)
        [~, min_i] = min(abs(f_axis - freq_map(k)));
        cand_indices(k) = min_i;
    end
    cand_indices_neg = zeros(size(freq_map));
    for k = 1:length(freq_map)
        [~, min_i] = min(abs(f_axis - (-freq_map(k))));
        cand_indices_neg(k) = min_i;
    end
    
    for i = 1:num_syms
        chunk = received_signal((i-1)*N_samp+1 : i*N_samp);
        Y = fftshift(fft(chunk));
        
        mags = abs(Y(cand_indices)) + abs(Y(cand_indices_neg));
        
        [~, best_idx] = max(mags);
        val = best_idx - 1;
        
        bits_stream = [bits_stream, dec2bin(val, bit_rate)];
    end
end