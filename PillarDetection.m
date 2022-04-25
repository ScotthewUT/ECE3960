%% LOOKS FOR A PILLAR IN FRONT OF BOT, RETURNS 'true' IF DETECTED
function detect_pillar = PillarDetection(bot)

pulseVal = bot.ultrasonicPulse;
scaleFactor = 10/610;
dist = scaleFactor * pulseVal;
fprintf("Pillar distance (cm): %0.0f \n", dist);

if dist < 20
    detect_pillar = true;
else 
    detect_pillar = false;
    
end
