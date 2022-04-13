function approach_pillar = Approach_Pillar(r)
MTR_R = 3;
MTR_L = 4;
r.servo(2,0)
pause(1)
r.motor(MTR_R, 9)
r.motor(MTR_L, 8)
pulseVal = r.ultrasonicPulse;
scaleFactor = 10/610;
dist = scaleFactor*pulseVal;

while (dist >= 3)
    r.motor(MTR_R, 9)
    r.motor(MTR_L, 8)
    pulseVal = r.ultrasonicPulse;
    dist = scaleFactor*pulseVal
end

r.motor(MTR_R, 0)
r.motor(MTR_L, 0)

pause(0.5)

r.motor(MTR_R, 9)
r.motor(MTR_L, 8)

pause(0.38)

r.motor(MTR_R, 0)
r.motor(MTR_L, 0)

r.servo(2,180)
end
