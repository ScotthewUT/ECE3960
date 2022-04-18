function ApproachPillar(bot)
MTR_R = 3;
MTR_L = 4;
SERVO_PIN = 2;

bot.servo(SERVO_PIN,0);
pause(1);
bot.motor(MTR_R, 9);
bot.motor(MTR_L, 8);
pulseVal = bot.ultrasonicPulse;
scaleFactor = 10/610;
dist = scaleFactor * pulseVal;

while (dist >= 3)
    bot.motor(MTR_R, 9);
    bot.motor(MTR_L, 8);
    pulseVal = bot.ultrasonicPulse;
    dist = scaleFactor * pulseVal;
end

bot.motor(MTR_R, 0)
bot.motor(MTR_L, 0)

pause(0.5)

bot.motor(MTR_R, 9)
bot.motor(MTR_L, 8)

pause(0.38)

bot.motor(MTR_R, 0)
bot.motor(MTR_L, 0)

end
