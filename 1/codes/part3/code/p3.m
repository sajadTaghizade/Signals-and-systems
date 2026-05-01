clear;
clc;
close all;

ts = 1e-9;     
T = 1e-5;       
tau = 1e-6;   
R = 450;       
alpha = 0.5;  
c = 3e8;     

t = 0:ts:T;

s_tx = zeros(size(t));
s_tx(t < tau) = 1;

td = (2 * R) / c;

s_rx = zeros(size(t));
received_pulse_indices = (t >= td) & (t < (td + tau));
s_rx(received_pulse_indices) = alpha;

%% 3-1 & 3-2

figure;
plot(t, s_tx, 'b', 'LineWidth', 2, 'DisplayName', 's_tx');
hold on;
plot(t, s_rx, 'r', 'LineWidth', 2, 'DisplayName', 's_rx');
grid on;
title('s_tx and s_rx Signals');
xlabel('Time');
ylabel('Amplitude');
legend('show');

%% 3-3

[correlation, lags] = xcorr(s_rx, s_tx);

[~, max_idx] = max(correlation);
estimated_lag_index = lags(max_idx);

estimated_td = estimated_lag_index * ts;

estimated_R = (estimated_td * c) / 2;

fprintf('Distance Estimation\n');
fprintf('Actual : %.2f m\n', R);
fprintf('Estimated : %.2f m\n\n', estimated_R);

figure;
plot(lags*ts, correlation);
title('Cross-Correlation of s_rx and s_tx');
xlabel('Time');
ylabel('Amplitude');
grid on;

%% 3-4

fprintf('Increasing Noise\n');

noise_powers = [0, 2, 4, 6, 8, 10, 15, 20];
num_trials = 100;
average_errors = zeros(size(noise_powers));

for i = 1:length(noise_powers)
    current_power = noise_powers(i);
    errors_for_this_power = zeros(1, num_trials);
    
    for j = 1:num_trials
        noise = sqrt(current_power) * randn(size(s_rx));
        s_rx_noisy = s_rx + noise;
        
        [correlation_noisy, lags_noisy] = xcorr(s_rx_noisy, s_tx);
        [~, max_idx_noisy] = max(correlation_noisy);
        estimated_lag_noisy = lags_noisy(max_idx_noisy);
        estimated_td_noisy = estimated_lag_noisy * ts;
        estimated_R_noisy = (estimated_td_noisy * c) / 2;
        
        errors_for_this_power(j) = abs(R - estimated_R_noisy);
    end
    
    average_errors(i) = mean(errors_for_this_power);
    fprintf('Noise Power: %.2f Average Error: %.2f m\n', current_power, average_errors(i));
end

figure;
plot(noise_powers, average_errors, 'o-', 'LineWidth', 2);
title('Average Error vs. Noise Power');
xlabel('Noise Power');
ylabel('Average Error');
grid on;
hold on;
plot(noise_powers, 10*ones(size(noise_powers)), 'r--', 'DisplayName', '10m Error Threshold');
legend('Average Error', '10m Threshold');
