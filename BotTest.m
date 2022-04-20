%% INITIALIZE
clear; clc; close all; instrreset;
pause(0.1);

IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;
MTR_MIN_SPD = 14;
SERVO_PIN = 2;

bot = MKR_MotorCarrier;
pause(0.1);
bot.startStream('analog');
pause(0.1);

%% GRAB BLOCK
bot.servo(SERVO_PIN, 0);
pause(0.5);
enc_val = GrabBlock(bot)



%% CALIBRATE IR SENSORS

ref_cal_mat = ReflectanceCalibrate();
    
%% NAIVE LINE FOLLOWING
bot.motor(MTR_R, MTR_MIN_SPD);
bot.motor(MTR_L, MTR_MIN_SPD);
while true
    ref = bot.readReflectance();
    if ref(IR_LL) < 500 && ref(IR_RR) < 500
        bot.motor(MTR_R, MTR_MIN_SPD);
        bot.motor(MTR_L, MTR_MIN_SPD);
    elseif ref(IR_LL) > 500
        bot.motor(MTR_R, MTR_MIN_SPD);
        bot.motor(MTR_L, -MTR_MIN_SPD);
    elseif ref(IR_RR) > 500
        bot.motor(MTR_R, -MTR_MIN_SPD);
        bot.motor(MTR_L, MTR_MIN_SPD);
    else
        fprintf("WHY?");
        bot.motor(MTR_R, -MTR_MIN_SPD);
        bot.motor(MTR_L, -MTR_MIN_SPD);
    end
end

%% PID LINE FOLLOWING
MTR_SPD = 12;
kp = 3;
ki = 0;
kd = 0;

error = 0;
error_sum = 0;
error_delta = 0;

while true
    ref = bot.readReflectance();
    for idx = 1:length(ref)
        ref(idx) = (ref(idx) - avg_data(1,idx))/(avg_data(2,idx) - avg_data(1,idx));
    end
    prev_err = error;
    error = -2 * ref(IR_RR) - ref(IR_CR) + ref(IR_CL) + 2 * ref(IR_LL);
    disp(error)
    %pause(0.5);
    
    mtr_r_ctrl = (kp * error) + (ki * error_sum) + (kd * error_delta) + MTR_SPD;
    mtr_l_ctrl = (kp * -error) + (ki * error_sum) + (kd * error_delta) + MTR_SPD;
    mtr_r_ctrl = round(mtr_r_ctrl);
    mtr_l_ctrl = round(mtr_l_ctrl);
    bot.motor(MTR_R, mtr_r_ctrl);
    bot.motor(MTR_L, mtr_l_ctrl);
end


%% SERVO CALIBRATION
 % f = 2.98x + 188 -- Apr 13
ENC_PIN   = 1;
SERVO_PIN = 2;

bot.startStream('analog');
pause(0.1);

pos_data = zeros(112, 2);

cmd = 90;
bot.servo(SERVO_PIN, cmd);
pause(1.2);

idx = 1;
while idx < 113
    rand = randi(181) - 1;
    if rand < cmd + 16 && rand > cmd - 16
        continue;
    end
    cmd = rand;
    bot.servo(SERVO_PIN, cmd);
    pause(1.5);
    analog_vals = bot.getAverageData('analog', 64);
    pos_data(idx, 1) = cmd;
    pos_data(idx, 2) = analog_vals(ENC_PIN);
    idx = idx + 1;
end

bot.stopStream('analog');

%% ROTATE
% 180 deg = 1300 counts
%  90 deg =  580 counts
% Reset motor encoders
bot.resetEncoder(MTR_R_ENC);
bot.resetEncoder(MTR_L_ENC);
pause(0.1);
[enc_R, enc_L] = bot.readEncoderPose();

target = 980;
% Rotate bot
while enc_R < target || enc_L < target
    pause(0.01);
    if enc_R < target
        bot.motor(MTR_R, 11);
    else
        bot.motor(MTR_R, 0);
    end
    if enc_L < target
        bot.motor(MTR_L, -11);
    else
        bot.motor(MTR_L, 0);
    end
    [enc_R, enc_L] = bot.readEncoderPose();
end

bot.motor(MTR_R, 0);
pause(0.025);
bot.motor(MTR_L, 0);

%%
BUZZER_PIN = 14;
bot.servo(SERVO_PIN, 0);
bot.digitalWrite(BUZZER_PIN, 1);
pause(3);
GrabBlock(bot);
bot.digitalWrite(BUZZER_PIN, 0);
pause(0.5);
data = ReadBlock(bot);
pause(0.5);
class = ClassifyBlock(data, myNeuralNetwork)
bot.servo(SERVO_PIN, 0);


%%
bot.motor(MTR_R,0);
bot.motor(MTR_L,0);