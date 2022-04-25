%% INITIALIZE
clear; clc; close all; instrreset;
pause(0.1);
bot = MKR_MotorCarrier;
pause(0.1);
bot.reflectanceSetup();

% DEFINE CONSTANTS
BUTTON_PIN = 13;
BUZZER_PIN = 14;
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;
MTR_R_ENC = 1;
MTR_L_ENC = 2;
SERVO_PIN = 2;

% INITIALIZE GLOBALS
block_class    = 0; % 0 = No Block, 1 = Bad, 2 = Good, 3 = Excellent
block_count    = 0;
bot_state      = "CALIBRATE";
ir_cal_data    = zeros(2, 4);
load("myNeuralNetwork.mat", "myNeuralNetwork");
servo_cal_line = [0, 0];

path_state     = zeros(1, 6);
% Path state is passed to PickPath for decision making:
%   [dir, loc, path_A, path_B, path_C, path_D]
%   dir: 0 = toward pillars, 1 = toward goals
%   loc: 0 = pillar side, 1 = center, 2 = goal side
%   paths: 0 = path needs exploring, 1 = path previously explored, 2 = dead end

% SET PIN MODES & BEGIN ANALOG INPUT STREAM
bot.pinMode(BUTTON_PIN, "input");
bot.pinMode(BUZZER_PIN, "output");
bot.startStream('analog');
pause(0.1);


%% STATE MACHINE
while true
    switch bot_state
        
        case "CALIBRATE"   % Initialized & now calibrating servo and IR sensor.
            [servo_cal_line(1), servo_cal_line(2)] = ServoCalibrate(bot);
            ir_cal_data = ReflectanceCalibrate(bot, 3);
            bot_state = "READY";
            
        case "READY"       % Calibrated and placed in starting position.
            % Path state: Facing pillars, center path, no paths explored.
            bot.reflectanceSetup();
            path_state = [0, 1, 1, 2 , 1 , 0];
            % Wait for button press to begin run.
            begin = 0;
            while begin == 0
                debounce_arr = zeros(1, 5);
                for idx = 1:5
                    debounce_arr = bot.digitalRead(BUTTON_PIN);
                    pause(0.01);
                end
                if all(debounce_arr)
                    begin = 1;
                end
                pause(0.1);
            end
            bot_state = "LINE FOLLOW";
            
        case "LINE FOLLOW" % Following line until intersection detected.
            intersection_detected = FollowLine(bot, ir_cal_data);
            if intersection_detected
                bot_state = "INTERSECTION";
            else
                bot_state = "LOST PATH";
            end
            
        case "INTERSECTION"   % At intersection and determing path choice.
            [bot_state, path_state] = Intersection(bot, path_state, block_class, ir_cal_data);
            disp(path_state)
            disp(bot_state)
            
        case "CHECK"       % At path end; checking for pillar.
            detect_pillar = PillarDetection(bot);
            if detect_pillar == true
                bot_state = "APPROACH";
            else
                bot_state = "RETREAT";
            end
            
        case "APPROACH"    % Approaching pillar.
            ApproachPillar(bot);
            bot_state = "GRAB";
            
        case "GRAB"        % Grabbing target with servo gripper.
            [encoder_val] = GrabBlock(bot);
            grab_object = true;
            bot_state="CLASSIFY";
            
        case "RETREAT"     % Retreating from pillar and returning to line.
            Retreat(bot, ir_cal_data);
            bot_state = "LINE FOLLOW";
            
        case "CLASSIFY"    % Classifying the currently held object.
            block_data = ReadBlock(bot);
            block_class = ClassifyBlock(block_data, myNeuralNetwork);
            bot_state = "RETREAT";
            
        case "DROP"        % Dropping object in goal.
            intersection_detected = FollowLine(bot, ir_cal_data);
            if intersection_detected
            grab_object = false;
            r.servo(2,0);
            end
            bot_state = "RETREAT";
            
        otherwise          % Should never be reached...
            fprintf("Oh balls! What happened?!\n");
            disp(path_state)
            break;
    end
end




%% SET MOTORS TO STOP (USED WHEN LEFT RUNNING AFTER ERRORS)
bot.motor(MTR_R,0);
bot.motor(MTR_L,0);