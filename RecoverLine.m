%%
function [line_found] = RecoverLine(bot, ir_cal_data)

% Define constants
ENC_INC = 200;
ENC_MAX = 700;
IR_LL = 4;
IR_RR = 1;
LINE_THR = 0.3;
MTR_L = 4;
MTR_R = 3;
MTR_L_ENC = 2;
MTR_R_ENC = 1;
MTR_SPD = 12;

% Initialize variables
enc_L = 0;
enc_R = 0;
line_found = 0;

% Try to find line by turning left slowly
bot.resetEncoder(MTR_R_ENC);
pause(0.05);
bot.motor(MTR_R, MTR_SPD);
while true
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data)
    [enc_R, ~] = bot.readEncoderPose();
    [enc_R, ~] = bot.readEncoderPose();
    if enc_R < -ENC_MAX || ENC_MAX < enc_R
        bot.motor(MTR_R, 0);
        line_found = 0;
        break;
    end
    if ref(IR_LL) > LINE_THR
        while ref(IR_LL) > LINE_THR
            ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
            ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
            bot.motor(MTR_R, MTR_SPD);
        end
        line_found = 1;
        bot.motor(MTR_R, 0);
        bot.resetEncoder(MTR_L_ENC);
        pause(0.05);
        [~, enc_L] = bot.readEncoderPose();
        [~, enc_L] = bot.readEncoderPose();
        while -ENC_INC < enc_L && enc_L < ENC_INC
            bot.motor(MTR_L, MTR_SPD);
            [~, enc_L] = bot.readEncoderPose();
            [~, enc_L] = bot.readEncoderPose();
        end
        bot.motor(MTR_L, 0);
        return;
    end
end

% Try to find line by turning right slowly
bot.resetEncoder(MTR_L_ENC);
pause(0.05);
bot.motor(MTR_L, MTR_SPD);
while true
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    [~, enc_L] = bot.readEncoderPose();
    [~, enc_L] = bot.readEncoderPose();
    if enc_L < -ENC_MAX * 3.5 || ENC_MAX * 3.5 < enc_L
        bot.motor(MTR_L, 0);
        line_found = 0;
        return;
    end
    if ref(IR_RR) > LINE_THR
        while ref(IR_RR) > LINE_THR
            ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
            ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
            bot.motor(MTR_L, MTR_SPD);
        end
        line_found = 1;
        bot.motor(MTR_L, 0);
        bot.resetEncoder(MTR_R_ENC);
        pause(0.05);
        [enc_R, ~] = bot.readEncoderPose();
        [enc_R, ~] = bot.readEncoderPose();
        while -ENC_INC < enc_R && enc_R < ENC_INC
            bot.motor(MTR_R, MTR_SPD);
            [enc_R, ~] = bot.readEncoderPose();
            [enc_R, ~] = bot.readEncoderPose();
        end
        bot.motor(MTR_R, 0);
        return;
    end
end

end
