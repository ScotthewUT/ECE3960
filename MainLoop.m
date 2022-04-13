%% INITIALIZE
clear; clc; close all; instrreset;
pause(0.1);
bot = MKR_MotorCarrier;
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
        case "LINE_FOLLOW"      % Following black line until intersection detected.
            intersection_detected = FollowLine(bot, ir_cal_data);
            if intersection_detected
                bot_state = "PICK PATH";
            end
        case "PICK PATH"   % At intersection and determing path choice.
            %double checking if bot is grabbing the object or not
            if grab_object== true %classification is good
                %pick the "GOOD" path to drop location
                bot_state= "LINE_FOLLOW";
            else
                
                bot_state=""
            end
        case "PATH_FOLLOW"
            intersection_detected = FollowLine(bot, ir_cal_data);
            if grab_object==true
                bot_state="DROP";
            else
                if intersection_detected
                 bot_state="CHECK";
                else 
                 bot_state="RETREAT";
            end
            end
        case "CHECK"       % At path end; checking for pillar.
            detect_pillar = Pillar_Detection(r)
            if detect_pillar == true
                bot_state = "APPROACH";
            else
                bot_state = "RETREAT";
            end
        case "APPROACH"    % Approaching pillar.
            approach_pillar = Approach_Pillar(r)
            bot_state="GRAB";
        case "GRAB"        % Grabbing target with servo gripper.
            [encoder_val]=GrabBlock(bot)
            grab_object = true;
            bot_state="CLASSIFY";
        case "RETREAT"     % Retreating from pillar and returning to line.
            %function for retreating the bot
            bot_state="LINE_FOLLOW";
        case "CLASSIFY"    % Classifying the currently held object.
            
            bot_state="RETREAT";
        case "DROP"        % Dropping object in goal.
            intersection_detected = FollowLine(bot, ir_cal_data);
            if intersection_detected
            grab_object=false;
            r.servo(2,0);
            end
            bot_state="RETREAT";
        otherwise          % Should never be reached...
    end
end




%% SET MOTORS TO STOP (USED WHEN LEFT RUNNING AFTER ERRORS)
bot.motor(MTR_R,0);
bot.motor(MTR_L,0);
