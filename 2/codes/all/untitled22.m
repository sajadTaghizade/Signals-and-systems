% =========================================================================
%      Script to Create the Farsi Character Dataset (.mat file)
%                  File: training_loading_Farsi.m
% =========================================================================
clc;
close all;
clear;

% !!! نام این پوشه باید دقیقاً با نام پوشه دیتابیس شما یکی باشد !!!
folder_name = 'Persian_Templates'; 

% خواندن تمام فایل‌های تصویری از پوشه
mapset_dir = dir(fullfile(folder_name, '*.png'));
if isempty(mapset_dir)
    mapset_dir = dir(fullfile(folder_name, '*.bmp')); % اگر فرمت bmp بود
end
if isempty(mapset_dir)
    error('هیچ فایل تصویری در پوشه "%s" پیدا نشد. لطفاً نام پوشه را چک کنید.', folder_name);
end

target_name = {mapset_dir.name};
target_len = length(target_name);

% ساختن یک آرایه سلولی برای ذخیره دیتابیس
% سطر اول: تصویر الگو
% سطر دوم: نام کاراکتر
data_table = cell(2, target_len);

for i = 1:target_len
    % خواندن و پردازش هر تصویر الگو
    img_path = fullfile(folder_name, target_name{i});
    img_raw = imread(img_path);
    
    % تبدیل به باینری (مهم)
    % تبدیل به باینری (مهم) - نسخه هوشمند
if size(img_raw, 3) == 3
    img_gray = rgb2gray(img_raw);
else
    img_gray = img_raw;
end

% --- FIX IS HERE ---
% قبل از باینری کردن، چک می‌کنیم که آیا از قبل باینری نیست
if ~islogical(img_gray)
    img_binary = imbinarize(img_gray);
else
    % اگر از قبل باینری بود، به آن دست نمی‌زنیم
    img_binary = img_gray;
end
% --- END OF FIX ---
    
    % ذخیره تصویر در جدول
    data_table{1, i} = img_binary;
    
    % استخراج نام کاراکتر از نام فایل (مثلاً از 'BB.png' کاراکتر 'ب' را می‌سازد)
    filename_base = extractBefore(target_name{i}, ".");
    
    % ترجمه نام فایل لاتین به کاراکتر فارسی
    switch filename_base
        case {'BB', 'b', 'B'}, character = 'ب';
        case {'DD', 'd', 'D'}, character = 'د';
        case {'JJ', 'j', 'J'}, character = 'ج';
        case {'GH', 'q', 'Q'}, character = 'ق';
        case {'HH', 'h', 'H'}, character = 'ه';
        case {'LL', 'l', 'L'}, character = 'ل';
        case {'MM', 'm', 'M'}, character = 'م';
        case {'NN', 'n', 'N'}, character = 'ن';
        case {'SA', 's', 'S'}, character = 'ص'; % فرض بر اینکه SA برای ص است
        case {'SS'}, character = 'س';
        case {'TA', 't', 'T'}, character = 'ط';
        case {'VV', 'v', 'V'}, character = 'و';
        case {'YY', 'y', 'Y'}, character = 'ی';
        case '0', character = '۰';
        case '1', character = '۱';
        case '2', character = '۲';
        case '3', character = '۳';
        case '4', character = '۴';
        case '5', character = '۵';
        case '6', character = '۶';
        case '7', character = '۷';
        case '8', character = '۸';
        case '9', character = '۹';
        otherwise, character = '?';
    end
    data_table{2, i} = character;
end

% ذخیره جدول نهایی در فایل .mat
save('Farsi_DATA_TABLE.mat', "data_table");
fprintf('فایل Farsi_DATA_TABLE.mat با موفقیت ساخته و ذخیره شد.\n');