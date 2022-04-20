%% SERVO CALIBRATION

function [slope, intercept] = ServoCalibrate(bot)

SAMPLES = 100;
DELAY = 1.5;
ENC_PIN   = 1;
SERVO_PIN = 2;
THR = 16;


cal_data = zeros(SAMPLES, 2);

cmd = 90;
bot.servo(SERVO_PIN, cmd);
pause(DELAY);

idx = 1;
while idx <= SAMPLES
    rand = randi(181) - 1;
    if rand < cmd + THR && rand > cmd - THR
        continue;
    end
    cmd = rand;
    bot.servo(SERVO_PIN, cmd);
    pause(DELAY);
    analog_vals = bot.getAverageData('analog', 64);
    cal_data(idx, 1) = cmd;
    cal_data(idx, 2) = analog_vals(ENC_PIN);
    idx = idx + 1;
end
cal_data = sortrows(cal_data);
fit_line = polyfit(cal_data(:,1), cal_data(:,2), 1);
slope = fit_line(1);
intercept = fit_line(2);

end

% f = 2.98x + 188  |  Apr 13
