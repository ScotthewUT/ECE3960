%% COMMANDS BOT TO BACK UP AND ABOUT-FACE
function Retreat(bot, ir_cal_data)

% Define constants
INCR  = 15;
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
IR_LL = 4;
L_THR = 0.3;
MTR_L = 4;
MTR_R = 3;
MTR_L_ENC = 2;
MTR_R_ENC = 1;
MTR_SPD = 12;

% Drive backward ~6 cm
DriveDistance(bot, 10, -12);

% Reset motor encoders
bot.resetEncoder(MTR_L_ENC);
bot.resetEncoder(MTR_R_ENC);
pause(0.1);
[enc_R, enc_L] = bot.readEncoderPose();
[enc_R, enc_L] = bot.readEncoderPose();

% About-face and return to path
target = 980;
bot.motor(MTR_L, -MTR_SPD);
bot.motor(MTR_R,  MTR_SPD);
% Turn bot about 140 deg \\ 90 deg = 580 counts, 180 deg = 1300 counts
while enc_R < target || enc_L < target
    pause(0.01);
    if enc_L < -target || target < enc_L
        bot.motor(MTR_L, 0);
    end
    if enc_R < -target || target < enc_R
        bot.motor(MTR_R, 0);
    end
    [enc_R, enc_L] = bot.readEncoderPose();
    [enc_R, enc_L] = bot.readEncoderPose();
end
bot.motor(MTR_R, 0);
bot.motor(MTR_L, 0);

% Look for edges of line with left IR sensor
ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data)
pause(0.05);
bot.motor(MTR_L, -9);
bot.motor(MTR_R, 9);
while ref(IR_LL) < L_THR
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data)
end
while ref(IR_LL) > L_THR
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data)
end
bot.motor(MTR_L, 0);
bot.motor(MTR_R, 0);
pause(0.05);

end
