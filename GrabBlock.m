function [enc_val] = GrabBlock(bot)

ENC_PIN   = 1;
SERVO_PIN = 2;
INC = 10;
THR = 2;

analog_vals = bot.getAverageData('analog', 15);
enc_val = round(analog_vals(ENC_PIN));
prev = enc_val;

cmd = INC;
bot.servo(SERVO_PIN, cmd);
pause(0.5);

while cmd < 181
    bot.servo(SERVO_PIN, cmd);
    pause(0.3);
    analog_vals = bot.getAverageData('analog', 15);
    enc_val = round(analog_vals(ENC_PIN));
    if enc_val < prev + THR
        enc_val = prev;
        break;
    end
    prev = enc_val;
    cmd = cmd + INC;
end

bot.servo(SERVO_PIN, cmd - INC);

end
