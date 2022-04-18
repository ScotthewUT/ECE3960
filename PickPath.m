function path = PickPath(r, pathState)
r.reflectanceSetup()
IR_LL = 4;

if pathState(3) == 0
    SelectPath = 1;
    else if pathState(4) == 0
        SelectPath = 2;
        else if pathState(5) == 0
                SelectPath = 3;
            else if pathState(6) == 0
                    SelectPath = 4;
                else
                    disp("Error")
                end
            end
        end
end

MTR_R = 3;
MTR_L = 4;

r.motor(MTR_R, 10)
r.motor(MTR_L, 10)

pause(1)

r.motor(MTR_R, 0)
r.motor(MTR_L, 0)

r.resetEncoder(1)
r.resetEncoder(2)
pause(0.1)
[val1, val2] = r.readEncoderPose()

% Rotate the bot 90 degrees
while val1 > -625 && val2 > -625
    [val1, val2] = r.readEncoderPose()
    pause(0.01)
    r.motor(MTR_R, -10)
    r.motor(MTR_L, 10)
end

pause(1)

drop = false;
while SelectPath > 0
    r.motor(MTR_R, 10)
    r.motor(MTR_L, -10)
    reflectance = r.readReflectance();
    pause(0.01)
    LR = reflectance(4);
    if LR > 1000
        SelectPath = SelectPath -1;
        drop = true;
        while drop == true
            reflectance = r.readReflectance();
            LR = reflectance(4);
            if LR < 1200
                drop = false;
            end
        end
    end
end
r.motor(MTR_R, 0)
r.motor(MTR_L, 0)   
    
    

end
