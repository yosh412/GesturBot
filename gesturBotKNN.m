% MATLAB file for the robot control of the gesturBot

% Author: Yoshua Schlenker and Lara Knoedler
% Date: 18.01.2024

%% Load KNN Network
% load KNN
% Have a look at trainKnn.m to understand the training
trainedModel = matfile('Model\MatlabModelKNN.mat').trainedModel;

%% Initialization
% Connection to ev3 brick
ev3brick = legoev3('USB');
writeStatusLight(ev3brick, 'red', 'solid');
sensorData = zeros(1, 32); % 1x32 matrix with zeros
% Variable for duration of timer, can be adapted by you
maxExecutionTime = 30;

% Initialization of infrared sensors
irSensorRight = irSensor(ev3brick, 3);
irSensorLeft = irSensor(ev3brick, 4);

% Initialization of motors
motorA = motor(ev3brick, 'A'); % For gripper
motorB = motor(ev3brick, 'B'); % For right wheel
motorC = motor(ev3brick, 'C'); % For left wheel

% Initialize display
clearLCD(ev3brick);
writeLCD(ev3brick, 'Gesture No: ',5, 2);

% Check battery level
% -> when to low, the IR sensor might not work properly
if ev3brick.BatteryLevel < 7
    warning('Low battery level, consider changing batterys');
    playTone(ev, 400, 0.3, 7);
    pause(0.5);
    playTone(ev, 400, 0.3, 7);
    pause(0.5);
    playTone(ev, 400, 0.3, 7);
end

%% State machine for robot control

% Reading data is similar to collectTrainData.m
% from line 52 to line 90
disp('The program will terminate itself after the specified duration')
% Start timer
startTime = tic;
writeStatusLight(ev3brick, 'orange', 'pulsing');

while toc(startTime) <= maxExecutionTime
    % Read one (current) value from each infrared sensor
    currentProximityLeftSensor = readProximity(irSensorLeft);
    currentProximityRightSensor = readProximity(irSensorRight);

    if currentProximityRightSensor < 28 || currentProximityLeftSensor < 28
         % Max distance is 75
            if currentProximityRightSensor > 75
                currentProximityRightSensor = 75;
            end
            if currentProximityLeftSensor > 75
                currentProximityLeftSensor = 75;
            end

        % Concatenate the single values in a matrix
        sensorData(1, 17) = currentProximityLeftSensor;
        sensorData(1, 1) = currentProximityRightSensor;

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
            sensorData(1, 16+i) = currentProximityLeftSensor;
            sensorData(1, i) = currentProximityRightSensor;

            % Sample rate 40ms
            pause(0.04);
        end

        % Predict the class/gesture number
        predicted = predict(trainedModel, sensorData) + 1;

        % Concatenat a string which is displayed
        feedbackString = strcat('Gesture No: ', num2str(predicted));

        % Refresh display
        clearLCD(ev3brick);
        writeLCD(ev3brick, char(feedbackString), 5, 2);
        disp(feedbackString);

        if predicted == 1 % Forward movement
            % Set speed
            motorA.Speed = 20;
            motorB.Speed = 20;
            motorC.Speed = 20;
            % Close gripper
            while readTouch(touchSens)
                start(motorA);
            end
            % Move forward
            start(motorB);
            start(motorC);

        elseif predicted == 2 % Backward movement
            motorA.Speed = 20;
            motorB.Speed = -20;
            motorC.Speed = -20;
            % Close gripper
            while readTouch(touchSens)
                start(motorA);
            end
            % Move backward
            start(motorB);
            start(motorC);

        elseif predicted == 3 % Stop
            motorA.Speed = -20;
            stop(motorB);
            stop(motorC);
            % Open gripper
            while ~readTouch(touchSens)
                start(motorA);
            end

        elseif predicted == 4 % No valid gesture
            % play error tone
            playTone(ev3brick, 400, 0.3, 5);
        end
    end
end
writeStatusLight(ev3brick, 'red', 'solid');
disp(strcat(num2str(maxExecutionTime),' seconds are over, restart the program'));
% Stop all motors
stop(motorA);
stop(motorB);
stop(motorC);
writeStatusLight(ev3brick, 'green', 'solid');
clearLCD(ev3brick);