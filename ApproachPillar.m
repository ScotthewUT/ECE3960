%% SLOWLY APPROACH PILLAR PRIOR TO GRABBING BLOCK
function ApproachPillar(bot)

MTR_L = 4;
MTR_R = 3;
MTR_SPD = 10;
SERVO_PIN = 2;
STOP_DIST = 3.5;

bot.servo(SERVO_PIN,0);
pulseVal = bot.ultrasonicPulse;
scaleFactor = 10/610;
dist = scaleFactor * pulseVal;
bot.motor(MTR_R, MTR_SPD);
bot.motor(MTR_L, MTR_SPD);

while (dist > STOP_DIST)
    pulseVal = bot.ultrasonicPulse;
    dist = scaleFactor * pulseVal;
end

bot.motor(MTR_R, 5);
bot.motor(MTR_L, 5);
DriveDistance(bot, 0.3, 8);

end
