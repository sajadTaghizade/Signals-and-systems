
alpha_true = 2.0;
beta_true = 5.0;

x_test = linspace(-10, 10, 200)'; 

y_ideal = alpha_true * x_test + beta_true;


%noise_strength = 5;
noise_strength = 1.5;

noise = noise_strength * randn(size(x_test));
y_noisy = y_ideal + noise;

[alpha_hat, beta_hat] = p24(x_test, y_noisy);


fprintf('--- Verification\n');
fprintf('True Alpha:      %.4f\n', alpha_true);
fprintf('Estimated Alpha: %.4f\n\n', alpha_hat);

fprintf('True Beta:       %.4f\n', beta_true);
fprintf('Estimated Beta:  %.4f\n\n', beta_hat);

figure;
plot(x_test, y_noisy, 'b.', 'DisplayName', 'Noisy Data Points');
hold on;
plot(x_test, y_ideal, 'c-', 'LineWidth', 3, 'DisplayName', 'True Line (Ideal)');
plot(x_test, alpha_hat * x_test + beta_hat, 'r--', 'LineWidth', 2, 'DisplayName', 'Estimated Line');
grid on;
legend('show');
title('Verification of Parameter Estimation');
xlabel('Test Input (x)');
ylabel('Test Output (y)');