
function [data] = data_gather(r)
r.servo(2,180)
pause(1)
disp("Hold the object close to sensor for 5 seconds to calibrate")
hall_data = r.analogRead(2);
[r,g,b] = r.rgbRead();
claw_data = r.analogRead(1);
data = [red,g,b,hall_data, claw_data];
for i=1:49
    hall_data=r.analogRead(2);
    [r,g,b] = r.rgbRead();
    claw_data = r.analogRead(1);
    temp = [red,g,b,hall_data, claw_data];
    data = [data; temp]
pause(0.1)
end
end

%r.rgbRead()