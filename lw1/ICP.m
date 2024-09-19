function [bunny_estR,bunny_estt, bunnyAlligned] = ICP(pts, ptsMoved, iters, DownsampleStep, visualize, percentage, tolerance, flag, useColour, slab1, slab2, partg, parte)
   
    bunny_estR = eye(3);
    bunny_estt = zeros(1,3);
    bunny_estR_prev = eye(3);
    bunny_estt_prev = zeros(1,3);
    
    consecutive_iter = 0;

    if parte == false 
        figure;
    end 
    for iter = 1: iters
        point_cloud_ds = pcdownsample(pointCloud(pts), 'random', DownsampleStep);
        pts_ds = point_cloud_ds.Location;
        point_cloud_ds_moved = pcdownsample(pointCloud(ptsMoved), 'random', DownsampleStep);
        ptsMoved_ds = point_cloud_ds_moved.Location;

        if useColour 
            slab1_ds = pcdownsample(slab1, 'random', DownsampleStep); 
            slab2_ds = pcdownsample(slab2, 'random', DownsampleStep);
            
            alpha = 0.009;
            [idx, dist] = knnsearch([pts_ds rgb2lab(slab1_ds.Color)], [ptsMoved_ds rgb2lab(slab2_ds.Color)], ...
                'K',1,'Distance','seuclidean', 'Scale', [1 1 1 alpha alpha alpha]);
        else 
            [idx, dist] = knnsearch(pts_ds,ptsMoved_ds,'K',1,'Distance','euclidean');
        end 
        
        
        size(pts_ds); %  54     3
        size(ptsMoved_ds); %  54     3
        size(idx); %  54     1
        size(dist); %  54     1
        size(pts_ds(idx,:)); %  54     3

        [~, sidx] = sort(dist);
        size(sidx); %  54     1
        f_idx = sidx(1:(round(percentage * length(idx))));
        size(f_idx); % 49     1
        f_dist = dist(f_idx); 
        size(f_dist); % 49     1
        size(idx(f_idx,:)); % 49     1

        % size( ptsMoved_ds(idx(f_idx,:),:) ); %   49     1
        % size(pts_ds(f_idx,:) ); % 49     3
        size( pts_ds(idx,:) ); %   54     3
        size(ptsMoved_ds ); % 54     3
         
        if partg == true 
            [bunny_estR,bunny_estt] = estimateRT_pt2pt1(pts_ds(idx,:), ptsMoved_ds);
        else 
            [bunny_estR,bunny_estt] = estimateRT_pt2pt(pts_ds(idx,:), ptsMoved_ds);
            % [bunny_estR,bunny_estt] = estimateRT_pt2pt(pts_ds(f_idx,:), ptsMoved_ds(idx(f_idx,:),:));
        end 
       
        if flag == true 
            temp = rotm2axang(bunny_estR); % 1x4 where last element is rotation angle
            prev_temp = rotm2axang(bunny_estR_prev);
            delta_R = abs(temp - prev_temp);
            delta_R = delta_R(4);
            delta_t = norm(bunny_estt - bunny_estt_prev);
    
            if  delta_R < tolerance(1) && delta_t < tolerance(2)
                consecutive_iter = consecutive_iter + 1;
            else
                consecutive_iter = 0;
            end
        end

 
        bunnyAlligned = pointCloud(rigidTransform(ptsMoved, bunny_estR, bunny_estt)); 
        
        if flag == true 
            if consecutive_iter == 3
                fprintf('Solution converged in %d iterations\n',iter);
                return;
            end
        end 
 
        if parte == false 
             
            if visualize && useColour == false
                pcshowpair(pointCloud(pts),bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100)
                % pcshow(slab1, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100), hold on;
                drawnow;
                disp(['ICP Iteration: ', num2str(iter)]);
            end
    
            if visualize == false && useColour == false % for part F: Aligned using point based ICP
                bunnyAlligned.Color = slab2.Color;
                % pcshowpair(slab1,bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100)
                pcshow(slab1, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100), hold on;
                pcshow(bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100), hold off;
                drawnow;
                disp(['ICP Iteration: ', num2str(iter)]);
            end
    
            if visualize == false && useColour % for part F: Aligned using color assisted ICP
                
                %pcshowpair(pointCloud(pts),bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100) 
                bunnyAlligned.Color = slab2.Color;
                %pcshowpair(slab1, bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100), hold on;
                pcshow(slab1, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100), hold on;
                pcshow(bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100), hold off;
                disp(['ICP Iteration color: ', num2str(iter)]);
                drawnow;
                
            end
        end


        ptsMoved = bunnyAlligned.Location; 
        bunny_estR_prev = bunny_estR;
        bunny_estt_prev = bunny_estt;
        
         
    end 

    if iter == iters
        disp('The number of iterations has reached its maximum.');
    end 
  
end


