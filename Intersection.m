%% STATE MACHINE THAT DETERMINES ACTION WHEN BOT REACHES AN INTERSECTION
function [bot_state, path_state] = Intersection(bot, prev_state, block_class, ir_cal_data)

% DEFINE CONSTANTS
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
MTR_R = 3;
MTR_L = 4;
MTR_R_ENC = 1;
MTR_L_ENC = 2;

% [dir, loc, path_A, path_B, path_C, path_D]
%  dir: 0 = toward pillars, 1 = toward goals
%  loc: 0 = pillar side, 1 = center, 2 = goal side
%  paths: 0 = path needs exploring, 1 = path previously explored, 2 = dead end
dir    = prev_state(1);
loc    = prev_state(2);
path_A = prev_state(3);
path_B = prev_state(4);
path_C = prev_state(5);
path_D = prev_state(6);
path_state = prev_state;

intrsctn = "UNKNOWN";

if dir == 0 && loc == 1
    % Headed toward pillars & reached branching intersection.
    intrsctn = "CENTER->PILLARS";
elseif dir == 0 && loc == 0
    % Headed toward pillars & reached end of path.
    intrsctn = "PILLAR";
elseif dir == 1 && loc == 0
    % Headed toward goals   & reached center path.
    intrsctn = "PILLARS->CENTER";
elseif dir == 1 && loc == 1
    % Headed toward goals   & reached goal branch.
    intrsctn = "CENTER->GOALS";
elseif dir == 1 && loc == 2
    % Headed toward goals   & reached a goal.
    intrsctn = "GOAL";
elseif dir == 0 && loc == 2
    % Headed toward pillars & reached center path.
    intrsctn = "GOALS->CENTER";
else
    % Shouldn't reach this case.
    fprintf("ERROR: UNKNOWN INTERSECTION!\n");
end

switch intrsctn
    case "CENTER->PILLARS"
        path = 0;
        while path == 0
            if path_A == 0
                path = 1;
            elseif path_B == 0
                path = 2;
            elseif path_C == 0
                path = 3;
            elseif path_D == 0
                path = 4;
            else
                for idx = 3:6
                    if prev_state(idx) ~= 2
                        path_state(idx) = 0;
                        path = idx - 2;
                    end
                end
            end
        end
        path_state(2) = 0;
        bot_state = "LINE FOLLOW";
        PickPath(bot, path, 0, ir_cal_data);
    case "PILLAR"
        bot_state = "CHECK";
    case "PILLARS->CENTER"
        DriveDistance(bot, 3, 10);
        path_state(2) = 1;
        bot_state = "LINE FOLLOW";
    case "CENTER->GOALS"
        if block_class == 1
            path = 1;
        else
            path = 2;
        end
        path_state(2) = 2;
        bot_state = "LINE FOLLOW";
        PickPath(bot, path, 0, ir_cal_data);
    case "GOAL"
        bot_state = "DROP";
    case "GOALS->CENTER"
        path_state(2) = 1;
        bot_state = "LINE FOLLOW";
        DriveDistance(bot, 3, 10);
    otherwise
end

end
