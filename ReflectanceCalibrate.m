%% CALIBRATE REFLECTANCE SENSOR
function [cal_data] = ReflectanceCalibrate()

IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;
MTR_SPD = 12;

r = MKR_MotorCarrier;
pause(0.02)
r.reflectanceSetup();
pause(0.02);
data = zeros(50, 4);
cal_data = zeros(2, 4);


fprintf("Place TBD Bot on light, path-free area.\n");
fprintf("Calibrating reflectance sensors...\n");
pause(0.5);
for count = 0:4
    r.setRGB(225,45,0);
    fprintf("%i\n",5 - count);
    pause(0.7);
    r.setRGB(0,0,0);
    pause(0.3);
end
r.setRGB(255,0,0);

r.motor(MTR_R, MTR_SPD);
r.motor(MTR_L,-MTR_SPD);
for row = 1:25
    ref = r.readReflectance();
    data(row,:) = ref(1,:);
    pause(0.15);
end
r.motor(MTR_R, 0);
r.motor(MTR_L, 0);
pause(0.5);
r.motor(MTR_R,-MTR_SPD);
r.motor(MTR_L, MTR_SPD);
for row = 26:50
    ref = r.readReflectance();
    data(row,:) = ref(1,:);
    pause(0.15);
end
r.motor(MTR_R, 0);
r.motor(MTR_L, 0);
r.setRGB(0,255,0);
cal_data(1,:) = mean(data);
cal_data(1,:) = round(cal_data(1,:));
fprintf("  LL |  CL |  CR |  RR\n");
fprintf(" %i | %i | %i | %i\n", cal_data(1,IR_LL), cal_data(1, IR_CL), ...
    cal_data(1, IR_CR), cal_data(1, IR_RR));

max_data = zeros(3,4);
for idx = 1:3
    fprintf("Place TBD Bot centered across black line path.\n");
    fprintf("Calibrating reflectance sensors...\n");
    pause(0.5);
    for count = 0:4
        r.setRGB(225,45,0);
        fprintf("%i\n",5 - count);
        pause(0.7);
        r.setRGB(0,0,0);
        pause(0.3);
    end
    r.setRGB(255,0,0);
    
    data = zeros(48,4);
    r.motor(MTR_R,-MTR_SPD);
    r.motor(MTR_L, MTR_SPD);
    for row = 1:8
        ref = r.readReflectance();
        data(row,:) = ref(1,:);
        pause(0.05);
    end
    r.motor(MTR_R, MTR_SPD);
    r.motor(MTR_L,-MTR_SPD);
    for row = 9:24
        ref = r.readReflectance();
        data(row,:) = ref(1,:);
        pause(0.05);
    end
    r.motor(MTR_R,-MTR_SPD);
    r.motor(MTR_L, MTR_SPD);
    for row = 25:40
        ref = r.readReflectance();
        data(row,:) = ref(1,:);
        pause(0.05);
    end
    r.motor(MTR_R, MTR_SPD);
    r.motor(MTR_L,-MTR_SPD);
    for row = 41:48
        ref = r.readReflectance();
        data(row,:) = ref(1,:);
        pause(0.05);
    end
    r.motor(MTR_R, 0);
    r.motor(MTR_L, 0);
    max_data(idx,:) = max(data);
end

cal_data(2,:) = mean(max_data);
cal_data(2,:) = round(cal_data(2,:));
fprintf("  LL |  CL |  CR |  RR\n");
fprintf(" %i | %i | %i | %i\n", cal_data(2, IR_LL),cal_data(2, IR_CL), ...
    cal_data(2, IR_CR), cal_data(2, IR_RR));

end
