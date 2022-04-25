%% INITIALIZE
clear; clc; close all; instrreset;
pause(0.1);
bot = MKR_MotorCarrier;
pause(0.1);
bot.reflectanceSetup();

% DEFINE CONSTANTS
BUTTON_PIN = 13;
BUZZER_PIN = 14;
DIR = 1;
LOC = 2;
PATH_A = 3;
PATH_B = 4;
PATH_C = 5;
PATH_D = 6;
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;
MTR_R_ENC = 1;
MTR_L_ENC = 2;
SERVO_PIN = 2;
SERVO_ENC_THR = 650;

% INITIALIZE GLOBALS
block_class    = 0; % 0 = No Block, 1 = Bad, 2 = Good, 3 = Excellent
block_count    = 0;
branch         = 2;
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
        % Initialized & now calibrating servo and IR sensor.
        case "CALIBRATE"
            %[servo_cal_line(1), servo_cal_line(2)] = ServoCalibrate(bot);
            ir_cal_data = ReflectanceCalibrate(bot, 3)
            bot_state = "READY"
        
        % Calibrated and placed in starting position.
        case "READY"
            % Just in case this wasn't ran.
            bot.reflectanceSetup();
            % Path state: Facing pillars, center path, no paths explored.
            path_state = [0, 1, 0, 2 , 0 , 0];
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
            % Happy beeps
            for beep = 1:3
                bot.digitalWrite(BUZZER_PIN, 1);
                pause(0.15);
                bot.digitalWrite(BUZZER_PIN, 0);
                pause(0.35);
            end
            pause(1);
            bot_state = "LINE FOLLOW"
            
        % Following line until intersection detected.    
        case "LINE FOLLOW"
            intersection_detected = FollowLine(bot, ir_cal_data);
            if intersection_detected
                bot_state = "INTERSECTION"
            else
                bot_state = "LOST PATH"
            end
        
        % At intersection and determing path choice.
        case "INTERSECTION"
            [bot_state, path_state] = Intersection(bot, path_state, block_class, ir_cal_data);
            disp(path_state)
            disp(bot_state)
            
        % At branch end; checking for pillar.
        case "CHECK"
            pillar_seen = PillarDetection(bot);
            if pillar_seen
                for beep = 1:2
                    bot.digitalWrite(BUZZER_PIN, 1);
                    pause(0.2);
                    bot.digitalWrite(BUZZER_PIN, 0);
                    pause(0.3);
                end
                path_state(branch) = 1;
                bot_state = "GET BLOCK"
            else
                % Mark as missing pillar on this branch
                path_state(branch) = 2;
                bot.digitalWrite(BUZZER_PIN, 1);
                pause(1);
                bot.digitalWrite(BUZZER_PIN, 0);
                Retreat(bot, ir_cal_data);
                path_state(DIR) = 1;
                path_state(LOC) = 0;
                bot_state = "LINE FOLLOW"
            end
            
        % Retrieving block and attempting to classify it.
        case "GET BLOCK"
            ApproachPillar(bot);
            pause(0.5);
            servo_val = GrabBlock(bot);
            while servo_val > SERVO_ENC_THR
                bot.digitalWrite(BUZZER_PIN, 1);
                bot.servo(SERVO_PIN, 0);
                pause(0.8);
                bot.digitalWrite(BUZZER_PIN, 0);
                servo_val = GrabBlock(bot);
            end
            pause(0.5);
            block_data = ReadBlock(bot);
            pause(0.05);
            block_class = ClassifyBlock(block_data, myNeuralNetwork);
            block_class = str2num(char(block_class));
            switch block_class
                case 1
                    fprintf("BAD BLOCK!\n");
                    bot.setRGB(255, 0, 0);
                case 2
                    fprintf("GOOD BLOCK!\n");
                    bot.setRGB(75, 0, 200);
                case 3
                    fprintf("EXCELLENT BLOCK!\n");
                    bot.setRGB(0, 255, 0);
                otherwise
                    fprintf("Error while classifying block!\n");
                    bot.digitalWrite(BUZZER_PIN, 1);
                    bot.servo(SERVO_PIN, 0);
                    pause(2);
                    bot.digitalWrite(BUZZER_PIN, 0);
            end
            for beep = 1:block_class
                bot.digitalWrite(BUZZER_PIN, 1);
                pause(0.2);
                bot.digitalWrite(BUZZER_PIN, 0);
                pause(0.5);
            end
            pause(1);
            Retreat(bot, ir_cal_data);
            path_state(DIR) = 1;
            block_count = block_count + 1;
            bot_state = "LINE FOLLOW"
        
        % Should never be reached...
        otherwise
            fprintf("Oh balls! What happened?!\n");
            disp(path_state)
            break;
    end
end


%% SET MOTORS TO STOP (USED WHEN LEFT RUNNING AFTER ERRORS)
bot.motor(MTR_R,0);
bot.motor(MTR_L,0);