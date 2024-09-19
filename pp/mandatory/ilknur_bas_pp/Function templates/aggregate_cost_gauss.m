% Cost Volume Aggregation with gaussian filtering
% Performs per-slice filtering of input cost volume
%
% Syntax: CostAgg = aggregate_cost_gauss(Cost, radius, simga);
% Cost - input 3D Cost Volume
% radius - radius of square window (size = radius*2 + 1)
% sigma - parameter of Gaussian filter
% CostAgg - aggregated cost

function CostAgg = aggregate_cost_gauss(Cost, radius, sigma)
    size = radius*2 + 1;
    h = fspecial('gaussian', [size size], sigma);
    CostAgg = imfilter(Cost, h);
end