% calculates cost volume out of two images
% Syntax: [CostL, CostR] = calculate_cost(L, R, maxdisp);
%
% Where:
% CostL - Cost volume assocuiated with Left image
% CostR - Cost volume assocuiated with Right image
% L, R - Left and Right input images
% mindisp, maxdisp - parameters, limiting disparity 
%
% Algorithm hints:
% for disp from 0 to maxdisp
%   CostL(y,x,disp) = |L(y,x,:)-R(y,x-disp,:)| 
%   CostR(y,x,disp) = |R(y,x,:)-L(y,x+disp,:)| 


function [CostLR, CostRL] = calculate_cost(L, R, maxdisp)
    L = double(L);
    R = double(R);
    [~, cols, ~] =  size(L); 

    CostLR = zeros(size(L,1), size(L,2), maxdisp + 1);
    CostRL = zeros(size(R,1), size(R,2), maxdisp + 1);

    for disp = 0:maxdisp 
        % cost of matching a pixel in left image with pixels in right image
        for x = (1 + disp):cols
            CostLR(:, x, disp+1) = sum(abs(L(:, x, :) - R(:, x - disp, :)), 3);
            CostLR(CostLR(:, x, disp+1) > 150, x, disp+1) = 150;
        end
         
        % cost of matching a pixel in right image with pixels in left image
        for x = 1:cols-disp
            CostRL(:, x, disp+1) = sum(abs(R(:, x, :) - L(:, x + disp, :)), 3);
            CostRL(CostRL(:, x, disp+1) > 150, x, disp+1) = 150;
        end
    end


end




