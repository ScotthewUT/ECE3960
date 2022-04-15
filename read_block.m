function [data] = read_block(r)
    %r = MKR_MotorCarrier;
    r.startStream('analog');
    hall_data = r.analogRead(2);
    pause(0.01)
    [red,g,b] = r.rgbRead();
    pause(0.01)
    claw_data = r.analogRead(1);
    data = [red,g,b,hall_data, claw_data];
end