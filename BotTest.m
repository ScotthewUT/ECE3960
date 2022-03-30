%% CALIBRATE REFLECTANCE SENSOR
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

%% CALIBRATE IR SENSORS

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
    
%% NAIVE LINE FOLLOWING
r.motor(MTR_R, MTR_MIN_SPD);
r.motor(MTR_L, MTR_MIN_SPD);
while true
    ref = r.readReflectance();
    if ref(IR_LL) < 500 && ref(IR_RR) < 500
        r.motor(MTR_R, MTR_MIN_SPD);
        r.motor(MTR_L, MTR_MIN_SPD);
    elseif ref(IR_LL) > 500
        r.motor(MTR_R, MTR_MIN_SPD);
        r.motor(MTR_L, -MTR_MIN_SPD);
    elseif ref(IR_RR) > 500
        r.motor(MTR_R, -MTR_MIN_SPD);
        r.motor(MTR_L, MTR_MIN_SPD);
    else
        fprintf("WHY?");
        r.motor(MTR_R, -MTR_MIN_SPD);
        r.motor(MTR_L, -MTR_MIN_SPD);
    end
end

%% PID LINE FOLLOWING ?
% r.motor(MTR_R, MTR_MIN_SPD);
% r.motor(MTR_L, MTR_MIN_SPD);
error = 0;
kp = 0.2;
ki = 0;
kd = 0;
while true
    ref = r.readReflectance();
    for idx = 1:length(ref)
        ref(idx) = (ref(idx) - avg_data(1,idx))/(avg_data(2,idx) - avg_data(1,idx));
    end
    prev_err = error;
    error = -2 * ref(IR_RR) - ref(IR_CR) + ref(IR_CL) + 2 * ref(IR_LL);
    disp(error)
    pause(0.5);
end


%%
r.motor(MTR_R,0);
r.motor(MTR_L,0);