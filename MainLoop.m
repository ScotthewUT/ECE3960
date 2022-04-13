%% INITIALIZE
clear; clc; close all; instrreset;
pause(0.1);
bot = MKR_MotorCarrier;
r = MKR_MotorCarrier;
pause(0.1);

% DEFINE CONSTANTS
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;

% INITIALIZE GLOBALS
bot_state = "CALIBRATE";


%% STATE MACHINE
while true
    switch bot_state
        case "CALIBRATE"   % Initialized & now calibrating IR sensor.
            ir_cal_data = ReflectanceCalibrate(bot);
            bot_state = "READY";
        case "READY"       % Calibrated and placed in starting position.
        case "FOLLOW"      % Following black line until intersection detected.
            intersection_detected = FollowLine(bot, ir_cal_data);
            if intersection_detected
                bot_state = "PICK PATH";
            end
        case "PICK PATH"   % At intersection and determing path choice.
        case "CHECK"       % At path end; checking for pillar.
            detect_pillar=Pilalr_Detection(r)
            if detect_pillar==true
                bot_state = "APPROACH";
            else 
                bot_state = "RETREAT"
        case "APPROACH"    % Approaching pillar.
            approach_pillar=Approach_Pillar(r)
            bot_state="GRAB"
        case "GRAB"        % Grabbing target with servo gripper.
        case "RETREAT"     % Retreating from pillar and returning to line.
        case "CLASSIFY"    % Classifying the currently held object.
        case "DROP"        % Dropping object in goal.
        otherwise          % Should never be reached...
    end
end




%% SET MOTORS TO STOP (USED WHEN LEFT RUNNING AFTER ERRORS)
bot.motor(MTR_R,0);
bot.motor(MTR_L,0);
