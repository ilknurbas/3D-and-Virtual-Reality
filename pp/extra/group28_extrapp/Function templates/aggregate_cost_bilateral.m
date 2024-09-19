% Cost Volume Aggregation with bilateral  filtering
% Performs per-slice filtering of input cost volume
%
% Syntax: CostAgg = aggregate_cost_guided(Cost, radius, simga);
% Cost - input 3D Cost Volume
% GuideImage - image to guide the filtering of the cost volume slices
% radius - radius of square window (size = radius*2 + 1)

% CostAgg - aggregated cost

function CostAgg = aggregate_cost_bilateral(cost, guideImage, radius )

    smoothValueDistance = 100;
    smoothValueColor = 100;
    % smoothValueDistance - parameter of Gaussian filter over distance
    % smootValueColor - parameter of Gaussian filter over color difference
    CostAgg = zeros(size(cost));
    
    % distance
    [m,n] = meshgrid(-radius:radius,-radius:radius);
    weightdeltadist = exp(-(sqrt(m.^2+n.^2).^2)./smoothValueDistance);
    
    for d = 1:size(cost,3)
        slice = cost(:, :, d);  

        for y = 1:size(cost,1)
            for x = 1:size(cost,2)
                % since kernel size is 2*radius+1
                ymin = max(y - radius, 1);
                ymax = min(y + radius, size(cost,1));
                xmin = max(x - radius, 1);
                xmax = min(x + radius, size(cost,2));

                neighbours = guideImage(ymin:ymax, xmin:xmax, :);  
                neighboursCost = slice(ymin:ymax, xmin:xmax);
                
                % color
                deltacolor = sqrt(sum((neighbours - guideImage(y, x, :)).^2, 3));
                weightdeltacolor = exp(-deltacolor.^2 ./ smoothValueColor);

                % distance
                weightdeltadistance = weightdeltadist((ymin:ymax)-y+radius+1,(xmin:xmax)-x+radius+1); 

                % apply
                weight = weightdeltacolor.*weightdeltadistance;
                CostAgg(y, x, d) = sum(sum(weight .* neighboursCost)) ./ sum(weight(:));

            end
        end   
    end

end