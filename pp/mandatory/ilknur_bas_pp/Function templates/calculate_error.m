% calculates percentage of bad pixels
% (pixels, with error larger than unity)
% 
% Syntax: [err] = calculate_error(Disp, GT)
% Disp - disparity map
% GT - ground truth to be compared against


function [err] = calculate_error(Disp, GT)
    bad = abs(Disp - GT) > 1;
    err = sum(bad(:))/numel(Disp);
end