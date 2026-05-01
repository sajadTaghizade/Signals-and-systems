
if ~exist('diabetes_validation', 'var')
    error('لطفا ابتدا فایل diabetes-validation را ایمپورت کنید');
end

predicted_val = trainedModel.predictFcn(diabetes_validation);

actual_val = table2array(diabetes_validation(:, end));

correct_val = sum(predicted_val == actual_val);
total_val = length(actual_val);

test_accuracy = (correct_val / total_val) * 100;

disp(['Test (Validation) Accuracy: ', num2str(test_accuracy), '%']);