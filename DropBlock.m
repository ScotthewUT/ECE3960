%% DROPS THE BLOCK (HOPEFULLY, IN THE GOAL)
function DropBlock(bot)

% Define constants
DIST = 8;
SPEED = 12;
SERVO_OPN = 0;
SERVO_PIN = 2;

% Drive forward 8 cm
DriveDistance(bot, DIST, SPEED);
% Open claw
bot.servo(SERVO_PIN, SERVO_OPN);
pause(0.05);

end
