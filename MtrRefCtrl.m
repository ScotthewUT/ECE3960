% PD controller that takes error terms from reflectance sensor and returns a
% motor duty-cycle commmand.
function [mtr_cmd] = MtrRefCtrl(error, error_delta)

MTR_SPD = 15;
MIN_MTR_SPD = 12;
MAX_MTR_SPD = 20;
KP = 2;
KD = 0.1;

mtr_cmd = (KP * error) + (KD * error_delta) + MTR_SPD;
mtr_cmd = round(mtr_cmd);

if mtr_cmd <  MIN_MTR_SPD
    mtr_cmd = MIN_MTR_SPD;
elseif mtr_cmd > MAX_MTR_SPD
    mtr_cmd = MAX_MTR_SPD;
end

end
