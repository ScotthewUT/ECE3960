%% INITIALIZE
clear; clc; close all; instrreset;
pause(0.05);
r = MKR_MotorCarrier;
pause(0.05);
r.reflectanceSetup();
pause(0.05);

% DEFINE CONSTANTS
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
IR_OUTER_WEIGHT = 2.5;
MTR_R = 3;
MTR_L = 4;


%% CALIBRATE IR SENSORS
ir_cal_data = ReflectanceCalibrate();


%% PRIMARY LINE-FOLLOWING LOOP
error = 0;
error_delta = 0;
prev_error = 0;
cnt = 0;
while true
    ref = CalibrateRefReading(r.readReflectance(), ir_cal_data);
    error = -IR_OUTER_WEIGHT * ref(IR_RR) - ref(IR_CR) + ref(IR_CL) + IR_OUTER_WEIGHT * ref(IR_LL);
    error_delta = error - prev_error;
    prev_err = error;
    
    r_mtr_cmd = MtrRefCtrl(error, error_delta);
    l_mtr_cmd = MtrRefCtrl(-error, -error_delta);
    
    r.motor(MTR_R, r_mtr_cmd);
    r.motor(MTR_L, l_mtr_cmd);
    
    if mod(cnt,12) == 0
        fprintf("Err = %.2f | R = %i | L = %i\n", round(error,2), r_mtr_cmd, l_mtr_cmd);
    end
    cnt = cnt + 1;
    
end


%% SET MOTORS TO STOP (USED WHEN LEFT RUNNING AFTER ERRORS)
r.motor(MTR_R,0);
r.motor(MTR_L,0);