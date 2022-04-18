function grab_object= drop_object(bot, classification)
    intersection_detected = FollowLine(bot, ir_cal_data);
    if intersection_detected
        if classification == 1
            bot.motor(MKR_R, 2)
            bot.motor(MKR_L, 10);
            FollowLine(bot, ir_cal_data);
            r.servo(2,0);
        elseif classification == 2
            bot.motor(MKR_R, 10)
            bot.motor(MKR_L, 2)
            FollowLine(bot, ir_cal_data);
            r.servo(2,0);
        else
            disp("I can't handle an excellent block yet");
        end
        
    end
    grab_object=false;
end