% READS IN BLOCK INFO FROM SERVO, COLOR SENSOR, AND HALL-EFFECT SENSOR
function [data] = ReadBlock(bot)

% Define constants
HALL_PIN   = 2;
SERVO_PIN  = 1;

% Just in case analog stream wasn't started
bot.startStream('analog');
% Get average analog values
analog_vals = bot.getAverageData('analog', 20);
pause(0.05);
hall_data = analog_vals(HALL_PIN);
claw_data = analog_vals(SERVO_PIN);
[r, g, b] = bot.rgbRead();

% hall_data = bot.analogRead(2);
% pause(0.02);
% [r,g,b] = bot.rgbRead();
% pause(0.02);
% claw_data = bot.analogRead(1);

data = [r,g,b,hall_data, claw_data];

end
