
function [data] = data_gather(r, Label)
r.startStream('analog');
r.servo(2,180)
pause(1)
disp("Hold the object close to sensor for 5 seconds to calibrate")
hall_data = r.analogRead(2);
[red,g,b] = r.rgbRead();
claw_data = r.analogRead(1);
data = [red,g,b,hall_data, claw_data, Label];
for i=1:49
    hall_data=r.analogRead(2);
    [red,g,b] = r.rgbRead();
    claw_data = r.analogRead(1);
    temp = [red,g,b,hall_data, claw_data, Label];
    data = [data; temp];
end
end