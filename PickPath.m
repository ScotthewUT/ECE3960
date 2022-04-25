%% BOT SWEEPS THE FLOOR LOOKING FOR THE SPECIFIED PATH FROM LEFT-RIGHT
function PickPath(bot, path, look_behind, ir_cal_data)

% Define constants
INCR  = 15;
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
IR_LL = 4;
L_THR = 0.5;
MTR_R = 3;
MTR_L = 4;
MTR_R_ENC = 1;
MTR_L_ENC = 2;

% Reset motor encoders
bot.resetEncoder(MTR_R_ENC);
bot.resetEncoder(MTR_L_ENC);
bot.resetEncoder(MTR_L_ENC);
bot.resetEncoder(MTR_R_ENC);
pause(0.1);
[enc_R, enc_L] = bot.readEncoderPose();

% If bot is retreating, find the single line behind it
if look_behind
    % Turn bot about 140 deg \\ 90 deg = 580 counts, 180 deg = 1300 counts
    target = 980;
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
    bot.motor(MTR_L, 0);
    
    % Look for edges of line with left IR sensor
    
    ref_RR = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    pause(0.1);
    ref_RR = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    pause(0.1);
    disp(ref_RR)
    bot.motor(MTR_R, 9);
    bot.motor(MTR_L, -9);
    while ref_RR(IR_LL) < L_THR
        ref_RR = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
        pause(0.02);
        disp(ref_RR)
    end
    while ref_RR(IR_LL) > L_THR
        ref_RR = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
        pause(0.02);
        disp(ref_RR)
    end
    bot.motor(MTR_R, 0);
    bot.motor(MTR_L, 0);
    return;
end

DriveDistance(bot, 3, 11);
% Turn bot about 140 deg \\ 90 deg = 580 counts, 180 deg = 1300 counts
target = 280;
while enc_R < target || enc_L < target
    pause(0.001);
    bot.motor(MTR_R, 11);
    bot.motor(MTR_L, -11);
%     if enc_R < target
%         bot.motor(MTR_R, 11);
%     else
%         bot.motor(MTR_R, 0);
%     end
%     if enc_L < target
%         bot.motor(MTR_L, -11);
%     else
%         bot.motor(MTR_L, 0);
%     end
    [enc_R, enc_L] = bot.readEncoderPose();
end
bot.motor(MTR_R, 0);
pause(0.02);
bot.motor(MTR_L, 0);




% % Look for edges of line with left IR sensor
% ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
% pause(0.1);
% bot.motor(MTR_R, -9);
% bot.motor(MTR_L, 9);
% while ref(IR_LL) < L_THR
%     ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
%     pause(0.01);
% end
% while ref(IR_LL) > L_THR
%     ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
%     pause(0.01);
% end
% bot.motor(MTR_R, 0);
% bot.motor(MTR_L, 0);
% 
% 
% 
% return





pause(3);
drop = false;
while path > 0
    bot.motor(MTR_R, -9)
    bot.motor(MTR_L, 9)
    ref = bot.readReflectance();
    pause(0.05);
    ref_RR = ref(IR_RR)
    if ref_RR > 1000
        path = path -1;
        drop = true;
        while drop == true
            ref = bot.readReflectance();
            ref_RR = ref(IR_RR);
            if ref_RR < 1200
                drop = false;
            end
        end
    end
end
bot.motor(MTR_R, 0)
pause(0.02);
bot.motor(MTR_L, 0)   

end
