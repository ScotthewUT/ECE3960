%% INITIALIZE
clear; clc; close all; instrreset;
pause(0.1);
%%
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;
MTR_MIN_SPD = 14;

r = MKR_MotorCarrier;
pause(0.1);

%% CALIBRATE IR SENSORS

ref_cal_mat = ReflectanceCalibrate();
    
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

%% PID LINE FOLLOWING
MTR_SPD = 12;
kp = 3;
ki = 0;
kd = 0;

error = 0;
error_sum = 0;
error_delta = 0;

while true
    ref = r.readReflectance();
    for idx = 1:length(ref)
        ref(idx) = (ref(idx) - avg_data(1,idx))/(avg_data(2,idx) - avg_data(1,idx));
    end
    prev_err = error;
    error = -2 * ref(IR_RR) - ref(IR_CR) + ref(IR_CL) + 2 * ref(IR_LL);
    disp(error)
    %pause(0.5);
    
    mtr_r_ctrl = (kp * error) + (ki * error_sum) + (kd * error_delta) + MTR_SPD;
    mtr_l_ctrl = (kp * -error) + (ki * error_sum) + (kd * error_delta) + MTR_SPD;
    mtr_r_ctrl = round(mtr_r_ctrl);
    mtr_l_ctrl = round(mtr_l_ctrl);
    r.motor(MTR_R, mtr_r_ctrl);
    r.motor(MTR_L, mtr_l_ctrl);
end


%%
r.motor(MTR_R,0);
r.motor(MTR_L,0);