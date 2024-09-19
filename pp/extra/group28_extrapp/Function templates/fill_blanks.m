function [ filledDisp ] = fill_blanks( Disp, outliers, Conf ) 
%UNTITLED Summary of this function goes here
%   Disp - Disparity map to be filtered
%   outliers - binary mask of pixels that should be filled
%   Conf - confidence values for the disparity map, if too low -> also fill

    m = 15;
    threshold = 0.01;
    filledDisp = zeros(size(Disp));
    paddedDisp = padarray(Disp, [(m-1)/2 (m-1)/2], 0);
    
    for n = 1:5
        for y = 1:size(Disp,1)
            for x = 1:size(Disp,2)
                if Conf(y,x) < threshold || outliers(y,x)  
                    % need to update outliers
                    outliers_updated = padarray(outliers,[(m-1)/2 (m-1)/2],1);
    
                    % perform filling
                    % get neighbours
                    row = y: y + ceil(m/2);
                    col = x: x + ceil(m/2);

                    for i=row
                        for j=col
                            if outliers_updated(i,j)
                                paddedDisp(i,j) = NaN; 
                            end
                        end
                    end
                    % get valid neighbours, MATLAB ignores NaN values
                    neighbours = paddedDisp(row, col);

                    filledDisp(y,x) = median(neighbours(:));
                    outliers(y,x) = 0; % valid pixel
    
               else
                   filledDisp(y,x) = Disp(y,x);
               end
    
           end
        end
    end

end




