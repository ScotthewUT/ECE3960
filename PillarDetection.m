function detect_pillar = PillarDetection(bot)
pulseVal = bot.ultrasonicPulse;
scaleFactor = 10/610;
dist = scaleFactor*pulseVal;
fprintf("Distance (cm): %0.0f \n", dist);

if dist < 25
    detect_pillar = true;
else 
    detect_pillar = false;
end
