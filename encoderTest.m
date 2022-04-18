r = MKR_MotorCarrier;
r.resetEncoder(1)
r.resetEncoder(2)
pause(0.1)
[val1, val2] = r.readEncoderPose()

MTR_R = 3;
MTR_L = 4;



r.motor(MTR_R, -10)
r.motor(MTR_L, 10)

tic;

while val1 > -625 && val2 > -625
    [val1, val2] = r.readEncoderPose()
    pause(0.01)
    r.motor(MTR_R, -10)
    r.motor(MTR_L, 10)
end

r.motor(MTR_R, 0)
pause(0.01)
r.motor(MTR_L, 0)
