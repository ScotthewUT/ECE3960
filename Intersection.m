%% STATE MACHINE THAT DETERMINES ACTION WHEN BOT REACHES AN INTERSECTION
function [bot_state, path_state] = Intersection(bot, prev_state, ir_cal_data)

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
        
    case "PILLAR"
        
    case "PILLARS->CENTER"
        
    case "CENTER->GOALS"
        
    case "GOAL"
        
    case "GOALS->CENTER"
        
    otherwise
end

end
