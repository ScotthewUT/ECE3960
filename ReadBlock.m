function [data] = ReadBlock(bot)
    %r = MKR_MotorCarrier;
    bot.startStream('analog');
    hall_data = bot.analogRead(2);
    pause(0.01)
    [red,g,b] = bot.rgbRead();
    pause(0.01)
    claw_data = bot.analogRead(1);
    data = [red,g,b,hall_data, claw_data];
end
