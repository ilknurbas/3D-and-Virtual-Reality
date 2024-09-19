% Finds disparity map from Cost Volume
% Syntax: [Disp] = winner_takes_all(Cost)
% Hints:
% for each (y,x) find the z (the layer) with the lowest cost value
% (note that matlab coordinates starts from 1, hence we need substract that unity)

function [Disp] = winner_takes_all(Cost)
    Disp = zeros(size(Cost,1), size(Cost,2));
    for y = 1:size(Cost,1)
        for x = 1:size(Cost,2)
            [~, idx] = min(Cost(y,x,:));
            Disp(y,x) = idx - 1;
        end
    end
end