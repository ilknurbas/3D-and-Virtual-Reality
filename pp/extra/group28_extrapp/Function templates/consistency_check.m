% Consistency check between two disparity maps (left & right)
% Performs per-slice filtering of input cost volume
%
% Syntax:  = consistency_check(dispL, dispR)
% dispL / dispR - input disparity map from left and right perspectives
% invalidPixelsL / invalidPixelsR - binary mask with inconsistent pixels marked with ones

function [ invalidPixelsL, invalidPixelsR] = consistency_check(dispL, dispR, threshold)
    invalidPixelsL = ones(size(dispL));
    invalidPixelsR = ones(size(dispR));

    for y = 1:size(dispL,1)
        for x = 1:size(dispL,2)
            dispLeft = dispL(y, x);
            xRight =  x - dispLeft ; % corresponding x-coordinate in the right image
            dispRight = dispR(y, x);
            xLeft = x + dispRight; 

            if xRight >= 1 && xRight <= size(dispL,2) 
                invalidPixelsL(y, x) = abs(dispL(y, x) - dispR(y, xRight)) > threshold;
            end

            if xLeft >= 1  && xLeft <= size(dispL,2) 
               invalidPixelsR(y, x) = abs(dispL(y, xLeft) - dispR(y, x)) > threshold;
            end

        end
    end 

end
    
    
