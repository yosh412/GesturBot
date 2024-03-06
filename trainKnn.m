% MATLAB file for the creation and training of the KNN of the gesturBot
% KNN means k-nearest-neighbors
% Therefore we need the gesture data which we collected upfront

% Author: Yoshua Schlenker and Lara Knoedler
% Date: 17.01.2024

%% Import training data

% Get path of currently running script
folderPath = mfilename("fullpath");

% Extract the directory of the script
scriptDirectory = fileparts(folderPath);

% Create the path to the subfolder Data
% When you stored the data in different subfolder:
% Change the subfolder variable to your subfolder name
subfolderData = 'Data'; 
dirData = fullfile(scriptDirectory, 'Data');

% Read train data
disp('Select your training data');
trainData = readCsvFiles(scriptDirectory, dirData);
xTrain = trainData(:, 1:32); % Samples
yTrain = trainData(:, 34); % Column 34 contains the classes

%% k-nearest neighbors model

k = 5;
trainedModel = fitcknn(xTrain, yTrain, Standardize=false, NumNeighbors=k, DistanceWeight="inverse");

%% Prediction on base of KNN model (accuracy testing)
% use the validation data from the Neural Network to
% calculate the accuracy of the KNN model
% A performance of > 0.9 is good
% Otherwise vary some params of the model, for example k, Standardize,
% DistanceWeight --> weights close points more than further ones

newData = readmatrix("Data\valData.csv");
labels = newData(:, 34);
newData = newData(:, 1:32);
amountRows = size(newData, 1);
predicted = zeros(80,2);
predicted(:, 2) = labels;

for i = 1:amountRows
    predicted(i) = predict(trainedModel, newData(i, :));
end

correct = 0;
for i=1:amountRows
    if predicted(i, 1) == predicted(i, 2)
        correct = correct + 1;
    end
end

prob = correct/80;
disp(prob);

%% Store NN
% Store the model only if the required performance is reached

if prob >= 0.9
    subfolderModel = 'Model';
    fullPath = strcat(subfolderModel, '\MatlabModelKNN.mat');
    
    % Make new directory
    if ~exist(subfolderModel, 'dir')
        mkdir(subfolderModel);
    end
    
    % Save the KNN
    % Existing models will be overwritten
    disp('------------Model is stored-------------');
    
    save(fullPath, "trainedModel");
else
    disp('Accuracy of the KNN model not sufficient, vary some params');
end