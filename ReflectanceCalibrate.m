%% CALIBRATE REFLECTANCE SENSOR
function [avg_data] = ReflectanceCalibrate()

IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;

r = MKR_MotorCarrier;
pause(0.02)
r.reflectanceSetup();
pause(0.02);
data = zeros(50, 4);
avg_data = zeros(2, 4);


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

r.motor(MTR_R, 20);
r.motor(MTR_L, -20);
for row = 1:25
    ref = r.readReflectance();
    data(row,:) = ref(1,:);
    pause(0.1);
end
r.motor(MTR_R, 0);
r.motor(MTR_L, 0);
pause(0.5);
r.motor(MTR_R, -20);
r.motor(MTR_L, 20);
for row = 26:50
    ref = r.readReflectance();
    data(row,:) = ref(1,:);
    pause(0.1);
end
r.motor(MTR_R, 0);
r.motor(MTR_L, 0);
r.setRGB(0,255,0);
avg_data(1,:) = mean(data);
avg_data(1,:) = round(avg_data(1,:));
fprintf("  LL |  CL |  CR |  RR\n");
fprintf(" %i | %i | %i | %i\n", avg_data(1,IR_LL), avg_data(1, IR_CL), ...
    avg_data(1, IR_CR), avg_data(1, IR_RR));

fprintf("Place TBD Bot centered on black line path.\n");
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

data = zeros(25,4);
for row = 1:25
    ref = r.readReflectance();
    data(row,:) = ref(1,:);
    pause(0.15);
end

avg_data(2,:) = mean(data);
avg_data(2,:) = round(avg_data(2,:));
fprintf("  LL |  CL |  CR |  RR\n");
fprintf(" %i | %i | %i | %i\n", avg_data(2, IR_LL),avg_data(2, IR_CL), ...
    avg_data(2, IR_CR), avg_data(2, IR_RR));

end
