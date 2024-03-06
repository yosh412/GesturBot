% MATLAB file for the creation and training of the NN of the gesturBot
% Therefore we need the gesture data which we collected upfront
% The architecture of the NN is 32-20-4 and the Adam Optimizer is used

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

% Read validation data
disp('Select your validation data');
valData = readCsvFiles(scriptDirectory, dirData);
xVal = valData(:, 1:32); % Samples
yVal = valData(:, 34); % Column 34 contains the classes

%% Normalization
% You need normalization so big values do not have an impact
% Max value from the irSensors: 75 -> see collectTrainingData.m
xTrain = xTrain./75.0;
xVal = xVal./75.0;

%% Categorical vector
yTrain = categorical(yTrain);
yVal = categorical(yVal);

%% Parameters of NN
n_in = 32;
n_hidden = 20;
n_out = 4;
n_epochs = 500;
learningRate = 0.001;


%% Definition of NN
% Create a neural network model
% Specify which layers are needed
% Specify some training options
layers = [
         featureInputLayer(n_in)
         fullyConnectedLayer(n_hidden)
         reluLayer
         fullyConnectedLayer(n_out)
         softmaxLayer
         classificationLayer];

options = trainingOptions("adam", ...
                          "Verbose",true, ...
                          "MaxEpochs", n_epochs, ...
                          "InitialLearnRate",learningRate, ...
                          "ValidationData", {xVal yVal}, ...
                          "Plots", "training-progress", ...
                          "MiniBatchSize", 100);

%% Train NN
[trainedModel, ~] = trainNetwork(xTrain, yTrain, layers, options);

%% Store NN
subfolderModel = 'Model';
fullPath = strcat(subfolderModel, '\MatlabModelNeuralNetwork.mat');

% Make new directory
if ~exist(subfolderModel, 'dir')
    mkdir(subfolderModel);
end

% Save the NN
% Existing models will be overwritten
disp('------------Model is stored-------------');

save(fullPath, "trainedModel");