function [data] = readCsvFiles(oldPath, newPath)
% reads the gesture data -> xTrain, yTrain, xTest, yTest
% Change the working directory
cd(newPath);

% Open a filedialog
[filename, filepath] = uigetfile('*.csv', 'Select .csv file', 'MultiSelect','off');
if isequal(filepath, 0) || isequal(filename, 0)
    error('You did not select a file')
else
    % Construct the complete file path
    fullFile = fullfile(filepath, filename);

    % Read in data
    data = readmatrix(fullFile);
end
cd(oldPath)
end