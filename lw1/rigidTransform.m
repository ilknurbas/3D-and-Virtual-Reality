function [t_pts] = rigidTransform(pts, R, t)
    t_pts = (pts * R)+ t;
end

