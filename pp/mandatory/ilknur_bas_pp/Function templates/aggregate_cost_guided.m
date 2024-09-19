% Cost Volume Aggregation with guided filtering
% Performs per-slice filtering of input cost volume
%
% Syntax: CostAgg = aggregate_cost_guided(Cost, radius, simga);
% Cost - input 3D Cost Volume
% GuideImage - image to guide the filtering of the cost volume slices
% radius - radius of square window (size = radius*2 + 1)
% sigma - parameter of Gaussian filter
% CostAgg - aggregated cost

function CostAgg = aggregate_cost_guided(cost, guideImage, radius, smoothValue)
    CostAgg = zeros(size(cost)); 
    for disp=1:size(cost,3)
        CostAgg(:,:,disp) = imguidedfilter(cost(:,:,disp), guideImage, ...
            'NeighborhoodSize', [radius*2 + 1 radius*2 + 1], ...
            'DegreeOfSmoothing',smoothValue);
    end
end

