% Cost Volume Aggregation with block averaging
% Performs per-slice averaging of input cost volume
%
% Syntax: CostAgg = aggregate_cost_block(Cost, radius);
% Cost - input 3D Cost Volume
% radius - radius of square window (size = radius*2 + 1)
% CostAgg - aggregated cost

function CostAgg = aggregate_cost_block(Cost, radius)
    size = radius*2 + 1;
    h = fspecial('average', size);
    CostAgg = imfilter(Cost, h);
end

