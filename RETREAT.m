function RETREAT(bot)
bot.resetEncoder(1)
bot.resetEncoder(2)
pause(0.1)
[val1, val2] = bot.readEncoderPose();

MTR_R = 3;
MTR_L = 4;

bot.motor(MTR_R, -8)
bot.motor(MTR_L, )

bot.motor(MTR_R, -10)
bot.motor(MTR_L, 10)


while val1 > -1320 && val2 > -1320
    [val1, val2] = bot.readEncoderPose();
    pause(0.01)
    bot.motor(MTR_R, -10)
    bot.motor(MTR_L, 10)
end

bot.motor(MTR_R, 0)
pause(0.01)
bot.motor(MTR_L, 0)
end