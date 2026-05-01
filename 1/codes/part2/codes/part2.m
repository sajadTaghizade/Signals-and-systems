clear;
clc;
close all;

load('p2.mat'); 

%% 2-1:
figure; 
plot(t, x);
title('Input Signal x(t)');
xlabel('Time (t)');
ylabel('x(t)');
grid on;

%% 2-2:
figure; 
plot(t, y);
title('Output Signal y(t) with Noise');
xlabel('Time (t)');
ylabel('y(t)');
grid on;

%% 2-3:
figure;
plot(x, y, '.');
title('y versus x');
xlabel('Input (x)');
ylabel('Output (y)');
grid on;
axis equal;


%% 2-4:
[alpha_estimated, beta_estimated] = p24(x, y);

fprintf('Estimated alpha (slope): %f\n', alpha_estimated);
fprintf('Estimated beta (intercept): %f\n', beta_estimated);

hold on;
plot(x, alpha_estimated * x + beta_estimated, 'r', 'LineWidth', 2);
legend('Data Points', 'Fitted Line');
hold off;