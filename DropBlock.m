%% 
function DropBlock(bot)

MTR_R = 3;
MTR_L = 4;
SERVO_PIN = 2;

bot.motor(MTR_R, 9);
bot.motor(MTR_L, 8);
pause(0.5);
bot.motor(MTR_R, 0);
bot.motor(MTR_L, 0);

bot.servo(SERVO_PIN, 180);

end
