function [R,t] = estimateRT_pt2pt(pts, ptsMoved)
 
    cpts = sum(pts,1)/size(pts,1);
    cptsMoved = sum(ptsMoved,1)/size(ptsMoved,1); 

    pts = pts - cpts;
    ptsMoved = ptsMoved - cptsMoved;

    covariance = pts'* ptsMoved;
    
    [U, ~, V] = svd(covariance);
    R = V * U';

    if det(R) < 0 % reflection matrix
        V(:,end) = -V(:, end); 
        R = V * U';
    end 

    t = cpts - (cptsMoved * R);
    
    
end

