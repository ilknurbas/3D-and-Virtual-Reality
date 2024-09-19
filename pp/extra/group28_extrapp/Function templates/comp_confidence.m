% Cost Volume Aggregation with block averaging
% Performs per-slice averaging of input cost volume
%
% Syntax: confidenceMap = comp_confidence(cost)
% Cost - input 3D Cost Volume
% confidenceMap - 2D map of confidence values for the disparity estimates

function confidenceMap = comp_confidence(cost)

   confidenceMap = ones(size(cost,1),size(cost,2));   

    for y = 1:size(cost,1)
        for x = 1:size(cost,2)
            costValues = squeeze(cost(y, x, :)); % 1x1xd --> dx1
            [~,locs] = findpeaks(-costValues); 

            if numel(locs) >= 2
                minA = costValues(locs(1));
                minB = costValues(locs(2));
                peakRatio = abs(minB - minA) / minB;
                confidenceMap(y, x) = peakRatio;
            
            elseif numel(locs) == 1
                confidenceMap(y, x) = 1; 

            elseif numel(locs) == 0
                confidenceMap(y, x) = 0; 
            end
            
        end
    end
    
end

