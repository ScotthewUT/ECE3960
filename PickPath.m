%% 
function PickPath(bot, path)

% Define constants
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;
MTR_R_ENC = 1;
MTR_L_ENC = 2;

% Reset motor encoders
bot.resetEncoder(MTR_R_ENC);
bot.resetEncoder(MTR_L_ENC);
pause(0.1);
[enc_R, enc_L] = bot.readEncoderPose();

% Rotate the bot 90 degrees
while enc_R > -625 && enc_L > -625
    pause(0.01);
    [enc_R, enc_L] = bot.readEncoderPose();
    bot.motor(MTR_R, -10);
    bot.motor(MTR_L, 10);
end

pause(1)

drop = false;
while path > 0
    bot.motor(MTR_R, 10)
    bot.motor(MTR_L, -10)
    reflectance = bot.readReflectance();
    pause(0.01)
    LR = reflectance(4);
    if LR > 1000
        path = path -1;
        drop = true;
        while drop == true
            reflectance = bot.readReflectance();
            LR = reflectance(4);
            if LR < 1200
                drop = false;
            end
        end
    end
end
bot.motor(MTR_R, 0)
bot.motor(MTR_L, 0)   

end
