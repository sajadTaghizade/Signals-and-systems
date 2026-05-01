clc;
clear;
close all;

disp('--- شروع بخش اول تمرین ---');

Mapset = create_mapset();
disp('تمرین ۱-۱: Mapset با ۳۲ کاراکتر ساخته شد.');

message = "signal";
fs = 100;
dt = 1/fs;

[sig1, t1] = coding_amp(message, 1, Mapset);
[sig2, t2] = coding_amp(message, 2, Mapset);
[sig3, t3] = coding_amp(message, 3, Mapset);

figure('Name', 'تمرین ۱-۳: کدگذاری پیام signal');
subplot(3, 1, 1);
plot(t1, sig1);
title(['پیام "signal" با Bit Rate = 1']);
xlabel('زمان (ثانیه)'); ylabel('دامنه');
grid on;

subplot(3, 1, 2);
plot(t2, sig2);
title(['پیام "signal" با Bit Rate = 2']);
xlabel('زمان (ثانیه)'); ylabel('دامنه');
grid on;

subplot(3, 1, 3);
plot(t3, sig3);
title(['پیام "signal" با Bit Rate = 3']);
xlabel('زمان (ثانیه)'); ylabel('دامنه');
grid on;

disp('--- تمرین ۱-۴: تست رمزگشایی بدون نویز ---');
decoded1 = decoding_amp(sig1, 1, Mapset);
decoded2 = decoding_amp(sig2, 2, Mapset);
decoded3 = decoding_amp(sig3, 3, Mapset);

disp(['Rate 1 (No Noise): ', decoded1]);
disp(['Rate 2 (No Noise): ', decoded2]);
disp(['Rate 3 (No Noise): ', decoded3]);
assert(strcmp(message, decoded1) && strcmp(message, decoded2) && strcmp(message, decoded3), 'خطا در کدگذاری/رمزگشایی!');

disp('--- تمرین ۱-۵: بررسی مشخصات نویز randn(1, 3000) ---');
noise_data = randn(1, 3000); 

mean_val = mean(noise_data);
var_val = var(noise_data);

disp(['(ب) میانگین نویز: ', num2str(mean_val), ' (نزدیک به صفر)']); 
disp(['(ج) واریانس نویز: ', num2str(var_val), ' (نزدیک به یک)']); 

figure('Name', 'تمرین ۱-۵: هیستوگرام نویز');
histogram(noise_data, 100, 'Normalization', 'pdf');
hold on;
x = -4:0.1:4;
pdf_gaussian = normpdf(x, 0, 1);
plot(x, pdf_gaussian, 'r-', 'LineWidth', 2);
title('(الف) هیستوگرام نویز (توزیع گوسی)'); 
legend('داده‌های randn', 'PDF گوسی استاندارد');

disp('--- تمرین ۱-۶: تست با نویز (Variance = 0.0001) ---');
noise_variance_low = 0.0001; 

noise_amp_low = sqrt(noise_variance_low);

noisy_sig1 = sig1 + (noise_amp_low * randn(size(sig1)));
noisy_sig2 = sig2 + (noise_amp_low * randn(size(sig2)));
noisy_sig3 = sig3 + (noise_amp_low * randn(size(sig3)));

decoded_noisy1 = decoding_amp(noisy_sig1, 1, Mapset);
decoded_noisy2 = decoding_amp(noisy_sig2, 2, Mapset);
decoded_noisy3 = decoding_amp(noisy_sig3, 3, Mapset);

disp(['Rate 1 (Noise Var 0.0001): ', decoded_noisy1]); 
disp(['Rate 2 (Noise Var 0.0001): ', decoded_noisy2]); 
disp(['Rate 3 (Noise Var 0.0001): ', decoded_noisy3]); 

disp('--- تمرین ۱-۷ و ۱-۸: افزایش تدریجی قدرت نویز ---');
noise_variances = logspace(-4, 0.5, 50); 
original_message = "signal";

max_robust_noise_r1 = 0;
max_robust_noise_r2 = 0;
max_robust_noise_r3 = 0;

for v = noise_variances
    noise_amp = sqrt(v);
    
    noisy_sig_r1 = sig1 + (noise_amp * randn(size(sig1)));
    decoded_r1 = decoding_amp(noisy_sig_r1, 1, Mapset);
    if strcmp(decoded_r1, original_message)
        max_robust_noise_r1 = v; 
    end
    
    noisy_sig_r2 = sig2 + (noise_amp * randn(size(sig2)));
    decoded_r2 = decoding_amp(noisy_sig_r2, 2, Mapset);
    if strcmp(decoded_r2, original_message)
        max_robust_noise_r2 = v;
    end
    
    noisy_sig_r3 = sig3 + (noise_amp * randn(size(sig3)));
    decoded_r3 = decoding_amp(noisy_sig_r3, 3, Mapset);
    if strcmp(decoded_r3, original_message)
        max_robust_noise_r3 = v;
    end
    
end

disp('--- نتایج نهایی تمرین ۱-۷ و ۱-۸ ---');
disp('**تمرین ۱-۷ (مشاهدات):**');
disp('با افزایش قدرت نویز، Bit rate های بالاتر (۲ و ۳) سریع‌تر دچار خطا در رمزگشایی شدند.');
disp('Bit rate = 1 بیشترین مقاومت را نسبت به نویز نشان داد.');
disp('این مشاهدات کاملاً با مقدمه همخوانی دارد:'); 
disp('چون در bit rate بالا، فاصله بین سطوح دامنه (و در نتیجه آستانه‌ها) کمتر است،'); 
disp('نویز راحت‌تر می‌تواند مقدار کورولیشن را از یک آستانه عبور داده و باعث تصمیم‌گیری اشتباه شود.'); 

disp(' ');
disp('**تمرین ۱-۸ (بیشترین واریانس نویز تقریبی):**'); 
disp(['Bit rate 1 مقاوم بود تا واریانس نویز تقریبی: ', num2str(max_robust_noise_r1)]);
disp(['Bit rate 2 مقاوم بود تا واریانس نویز تقریبی: ', num2str(max_robust_noise_r2)]);
disp(['Bit rate 3 مقاوم بود تا واریانس نویز تقریبی: ', num2str(max_robust_noise_r3)]);