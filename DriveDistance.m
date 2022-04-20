%% COMMANDS THE BOT TO DRIVE FORWARD/BACKWARD A GIVEN DISTANCE IN CM
function DriveDistance(bot, dist, spd)

% DEFINE CONSTANTS
ENC_PER_CM = 65.5; % (1440 counts/rev) / (2 * pi * 3.5 cm) = 65.5
MTR_R = 3;
MTR_L = 4;
MTR_R_ENC = 1;
MTR_L_ENC = 2;

% RESET MOTOR ENCODERS
bot.resetEncoder(MTR_R_ENC);
bot.resetEncoder(MTR_L_ENC);
pause(0.1);
[enc_R, enc_L] = bot.readEncoderPose();

% SPIN MOTORS AT GIVEN SPEED UNTIL ENCODER COUNT REACHES TARGET
tar_count = dist * ENC_PER_CM; 
while enc_R < tar_count && enc_L < tar_count
    if enc_R < tar_count
        bot.motor(MTR_R, spd);
    else
        bot.motor(MTR_R, 0);
    end
    if enc_L < tar_count
        bot.motor(MTR_L, spd);
    else
        bot.motor(MTR_L, 0);
    end
    [enc_R, enc_L] = bot.readEncoderPose();
    pause(0.02);
end
bot.motor(MTR_R, 0);
bot.motor(MTR_L, 0);

end
