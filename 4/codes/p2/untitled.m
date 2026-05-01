
if ~exist('diabetes_training', 'var')
    error('لطفا ابتدا فایل diabetes-training را ایمپورت کنید');
end


predicted_labels = trainedModel.predictFcn(diabetes_training);

actual_labels = table2array(diabetes_training(:, end));
correct_predictions = sum(predicted_labels == actual_labels);
total_samples = length(actual_labels);

train_accuracy = (correct_predictions / total_samples) * 100;

disp(['Manual Training Accuracy: ', num2str(train_accuracy), '%']);