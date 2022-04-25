%% CALIBRATE REFLECTANCE SENSOR
function [cal_data] = ReflectanceCalibrate(bot, samples)

% Define constants
BUZZER_PIN = 14;
CAL_THR = [50, 300; 1000, 2500];
IR_LL = 4;
IR_CL = 3;
IR_CR = 2;
IR_RR = 1;
MTR_L = 4;
MTR_R = 3;
MTR_L_ENC = 2;
MTR_R_ENC = 1;
MTR_ROT = 350;
MTR_SPD = 11;
TIME = 15;

% Initialize data matrices
min_data = zeros(samples, 4);
max_data = zeros(samples, 4);
cal_data = zeros(2, 4);

% Ensure IR sensor was initialized
bot.reflectanceSetup();
pause(0.1);

% Repeat IR data collection specified number of times
for iter = 1:samples

    % Reset motor encoders
    bot.resetEncoder(MTR_L_ENC);
    pause(0.1);
    bot.resetEncoder(MTR_R_ENC);
    pause(0.1);

    % Warn user with countdown
    fprintf("Place TBD Bot with IR sensor right of line.\n");
    fprintf("Calibrating reflectance sensors...\n");
    pause(0.5);
    for count = 0:4
        bot.setRGB(225,45,0);
        bot.digitalWrite(BUZZER_PIN, 0);
        fprintf("%i\n",5 - count);
        pause(0.7);
        bot.setRGB(0,0,0);
        bot.digitalWrite(BUZZER_PIN, 1);
        pause(0.3);
    end
    bot.setRGB(255,0,0);
    bot.digitalWrite(BUZZER_PIN, 0);

    % Pivot over line while collecting IR data
    dir = 1;
    row = 1;
    toggle_L = 0;
    toggle_R = 0;
    tic;
    bot.motor(MTR_L, MTR_SPD * dir * -1);
    bot.motor(MTR_R, MTR_SPD * dir);
    while toc < TIME
        ref = bot.readReflectance();
        ref = bot.readReflectance();
        data(row,:) = ref(1,:);
        [enc_R, enc_L] = bot.readEncoderPose();
        [enc_R, enc_L] = bot.readEncoderPose();
        if enc_L < -MTR_ROT || MTR_ROT < enc_L
            bot.motor(MTR_L, 0);
            toggle_L = 1;
        end
        if enc_R < -MTR_ROT || MTR_ROT < enc_R
            bot.motor(MTR_R, 0);
            toggle_R = 1;
        end
        if toggle_L && toggle_R
            toggle_L = 0;
            toggle_R = 0;
            dir = dir * -1;
            bot.motor(MTR_L, MTR_SPD * dir * -1);
            bot.motor(MTR_R, MTR_SPD * dir);
            pause(0.2);
        end
    end
    bot.motor(MTR_L, 0);
    bot.motor(MTR_R, 0);
    % Get the min and max from data set then repeat
    min_data(iter,:) = min(data);
    max_data(iter,:) = max(data);
    clear data;
end
% Average the samples and return the calibration data
cal_data(1,:) = round(mean(min_data));
cal_data(2,:) = round(mean(max_data));

% Verify the calibration looks reasonable
for idx = 1:4
    if cal_data(1, idx) < CAL_THR(1, 1) || cal_data(1, idx) > CAL_THR(1, 2) ...
    || cal_data(2, idx) < CAL_THR(2, 1) || cal_data(1, idx) > CAL_THR(2, 2)
        cal_data = zeros(2, 4);
        bot.setRGB(255, 0, 0);
        bot.digitalWrite(BUZZER_PIN, 1);
        pause(1.5);
        bot.digitalWrite(BUZZER_PIN, 0);
        pause(0.1);
        return
    end
end
bot.setRGB(0, 255, 0);
bot.digitalWrite(BUZZER_PIN, 1);
pause(0.1);
bot.digitalWrite(BUZZER_PIN, 0);
pause(0.2);
bot.digitalWrite(BUZZER_PIN, 1);
pause(0.1);
bot.digitalWrite(BUZZER_PIN, 0);
pause(0.2);
bot.digitalWrite(BUZZER_PIN, 1);
pause(0.1);
bot.digitalWrite(BUZZER_PIN, 0);
end


%% OLD METHOD
% data = zeros(50, 4);
% cal_data = zeros(2, 4);
% 
% fprintf("Place TBD Bot on light, path-free area.\n");
% fprintf("Calibrating reflectance sensors...\n");
% pause(0.5);
% for count = 0:4
%     bot.setRGB(225,45,0);
%     fprintf("%i\n",5 - count);
%     pause(0.7);
%     bot.setRGB(0,0,0);
%     pause(0.3);
% end
% bot.setRGB(255,0,0);
% 
% bot.motor(MTR_R, MTR_SPD);
% bot.motor(MTR_L,-MTR_SPD);
% for row = 1:25
%     ref = bot.readReflectance();
%     data(row,:) = ref(1,:);
%     pause(0.15);
% end
% bot.motor(MTR_R, 0);
% bot.motor(MTR_L, 0);
% pause(0.5);
% bot.motor(MTR_R,-MTR_SPD);
% bot.motor(MTR_L, MTR_SPD);
% for row = 26:50
%     ref = bot.readReflectance();
%     data(row,:) = ref(1,:);
%     pause(0.15);
% end
% bot.motor(MTR_R, 0);
% bot.motor(MTR_L, 0);
% bot.setRGB(0,255,0);
% cal_data(1,:) = mean(data);
% cal_data(1,:) = round(cal_data(1,:));
% fprintf("  LL |  CL |  CR |  RR\n");
% fprintf(" %i | %i | %i | %i\n", cal_data(1,IR_LL), cal_data(1, IR_CL), ...
%     cal_data(1, IR_CR), cal_data(1, IR_RR));
% 
% max_data = zeros(3,4);
% for idx = 1:3
%     fprintf("Place TBD Bot centered across black line path.\n");
%     fprintf("Calibrating reflectance sensors...\n");
%     pause(0.5);
%     for count = 0:4
%         bot.setRGB(225,45,0);
%         fprintf("%i\n",5 - count);
%         pause(0.7);
%         bot.setRGB(0,0,0);
%         pause(0.3);
%     end
%     bot.setRGB(255,0,0);
% 
%     data = zeros(48,4);
%     bot.motor(MTR_R,-MTR_SPD);
%     bot.motor(MTR_L, MTR_SPD);
%     for row = 1:8
%         ref = bot.readReflectance();
%         data(row,:) = ref(1,:);
%         pause(0.05);
%     end
%     bot.motor(MTR_R, MTR_SPD);
%     bot.motor(MTR_L,-MTR_SPD);
%     for row = 9:24
%         ref = bot.readReflectance();
%         data(row,:) = ref(1,:);
%         pause(0.05);
%     end
%     bot.motor(MTR_R,-MTR_SPD);
%     bot.motor(MTR_L, MTR_SPD);
%     for row = 25:40
%         ref = bot.readReflectance();
%         data(row,:) = ref(1,:);
%         pause(0.05);
%     end
%     bot.motor(MTR_R, MTR_SPD);
%     bot.motor(MTR_L,-MTR_SPD);
%     for row = 41:48
%         ref = bot.readReflectance();
%         data(row,:) = ref(1,:);
%         pause(0.05);
%     end
%     bot.motor(MTR_R, 0);
%     bot.motor(MTR_L, 0);
%     max_data(idx,:) = max(data);
% end
% 
% cal_data(2,:) = mean(max_data);
% cal_data(2,:) = round(cal_data(2,:));
% fprintf("  LL |  CL |  CR |  RR\n");
% fprintf(" %i | %i | %i | %i\n", cal_data(2, IR_LL),cal_data(2, IR_CL), ...
%     cal_data(2, IR_CR), cal_data(2, IR_RR));
% 
% bot.motor(MTR_L, 0);
% bot.motor(MTR_R, 0);
% end