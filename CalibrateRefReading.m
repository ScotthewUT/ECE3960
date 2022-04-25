%% CALIBRATE IR REFLECTANCE READINGS
function [adj_rdng] = CalibrateRefReading(readings, cal_data)

IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;

adj_rdng = zeros(1,4);

for idx = 1:length(adj_rdng)
    adj_rdng(idx) = (readings(idx) - cal_data(1,idx)) / (cal_data(2,idx) - cal_data(1,idx));
end

end