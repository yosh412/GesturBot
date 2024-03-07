% MATLAB file to create validation data for the gestures of the gesturBot
% Similar to the collectTrainData.m

% Author: Yoshua Schlenker and Lara Knoedler
% Date: 17.01.2024

%% Initialization
% Connection to the ev3, via USB is sufficient for reading gesture data
ev3brick = legoev3('USB');

% Initialization of some variables
% We collect 20 different values for each gesture for the valdiation
gesture = 0; % 3 gestures plus 1 for no gesture
amountValData = 80; % 20*4
x = 1; % counter
sensorData = zeros(1, 34); % 1x32 matrix with zeros

% Initialization of the two infrared sensors
% -> view from the display of the ev3 brick
irSensorRight = irSensor(ev3brick, 3);
irSensorLeft = irSensor(ev3brick, 4);

% Initialize display
clearLCD(ev3brick);
initString = strcat('Gesture Number: ', string(gesture));
writeLCD(ev3brick, 'Read Training Data', 2, 1);
writeLCD(ev3brick, char(initString), 4, 1);
writeLCD(ev3brick, strcat('Sample Number: ', char(num2str(mod(x, amountValData/4)))), 6, 1);
disp(strcat('Sample Number: ', char(num2str(mod(x, amountValData/4)))));

%% Data storage in matrix
% Loop determindes how many gestures are read

    while x <= amountValData
        % Read one (current) value from each infrared sensor
        currentProximityLeftSensor = readProximity(irSensorLeft);
        currentProximityRightSensor = readProximity(irSensorRight);
    
        if currentProximityRightSensor < 30 || currentProximityLeftSensor < 30
             % Max distance is 75
                if currentProximityRightSensor > 75
                    currentProximityRightSensor = 75;
                end
                if currentProximityLeftSensor > 75
                    currentProximityLeftSensor = 75;
                end
                
            % Concatenate the single values in a matrix
            sensorData(x+1, 17) = currentProximityLeftSensor;
            sensorData(x+1, 1) = currentProximityRightSensor;
    
            pause(0.04);
    
            for i = 2:16
                % Read one (current) value from each infrared sensor
                currentProximityLeftSensor = readProximity(irSensorLeft);
                currentProximityRightSensor = readProximity(irSensorRight);
    
                % Max distance is 75
                if currentProximityRightSensor > 75
                    currentProximityRightSensor = 75;
                end
                if currentProximityLeftSensor > 75
                    currentProximityLeftSensor = 75;
                end
    
                % Concatenate the single values in a matrix
                sensorData(x+1, 16+i) = currentProximityLeftSensor;
                sensorData(x+1, i) = currentProximityRightSensor;
                sensorData(x+1, 34) = gesture; 
    
                % Sample rate 40ms
                pause(0.04);
            end
    
            % Audio feedback
            playTone(ev3brick, 400, 0.3, 5);
            
            % Increase number of gesture if 20 samples/gesture collected
            if (mod(x, amountValData/4) == 0) && x ~= 0
                gesture = gesture + 1;
            end
    
            % Refresh display
            clearLCD(ev3brick);
            writeLCD(ev3brick, 'Read Validation Data', 2, 1);
            initString = strcat('Gesture Number: ', string(gesture));
            writeLCD(ev3brick, char(initString), 4, 1);
            writeLCD(ev3brick, strcat('Sample Number: ', char(num2str(mod(x, amountValData/4)))), 6, 1);
            disp(strcat('Sample Number: ', char(num2str(mod(x, amountValData/4)))));

            % Increase count variable
            x = x + 1;
        end
    end

%% Data processing
% Store matrix of sensor values in a .csv
writematrix(sensorData(2:end,:), 'Data\valData.csv');