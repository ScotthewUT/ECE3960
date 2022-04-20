%% COMMANDS BOT TO BACK UP AND ABOUT-FACE
function Retreat(bot, ir_cal_data)

% Drive backward 4 cm
DriveDistance(bot, 10, -12);
% About-face and return to path
PickPath(bot, 1, 1, ir_cal_data);

end
