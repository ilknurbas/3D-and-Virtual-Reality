%--------------------------------------------------------------------------
% COMP.SGN.320 3D and Virtual Reality 
%
%
% Your implementation should run by executing this m-file ("run LW2.m"), 
% but feel free to create additional files for your own functions
% Make sure it runs without errors after unzipping
%
% Fill out the information below
%
% Group members: Ilknur Bas
% Additional tasks completed (5, 6, 7, 8): 
% For synthetic data all tasks including additional tasks work.
% For Kinect data: 
%   I am not sure about the outputs of Task 2-4
%   Task 5 takes a lot of time.  
%   Task 7 don't work

% Fill in your implementation at the assigned slots. You can use the 
% existing drawing scripts or draw your own figures. 
% To give an impression of the scope of each task, 
% the number of lines of code in the reference implementation is given
% This is highly subjective depending on coding style, and should not
% be considered as a requirement. Use as much code as you need, but if you
% start having 10 times the lines, you may consider that there might be an
% easier way to do it.
%--------------------------------------------------------------------------
clear
close all
% Load synthetic data:

% Load real data:
%   .Depth from Kinect is in "mm";
%   .Translation vector is in "mm";
%   .Intrinsic parameters are in "pixels";
  
% load KinectData.mat 
% Image = imread('./Color_rect.tif');
% Depth = imread('./Depth_rect.tif'); 

isKinetic = 0; % note: change this
if isKinetic
    load KinectData
    Image = imread('Colour_000.tif');
    Depth = imread('Depth_000.tif'); 
    lr = imread('Ir_000.tif'); 
else 
    load synthdata
end

%% Task 1: Plotting global point cloud (8 lines of code)
% Back projection from PMD image plane to global space 
figure;
subplot(1,2,1), imshow(Image);
subplot(1,2,2), imshow(Depth, []);

%%
[u,v] = meshgrid(1:size(Depth,2), 1:size(Depth,1)); % cols, rows

if isKinetic
    fx = Dparam.fx ;
    fy = Dparam.fy ;
   
    Depth(Depth == 0) = NaN;
    %0.5 and 4.5 meters to mm
    Depth(Depth < 500 | Depth > 4500) = NaN;

    u_x = u - (Dparam.cx);
    u_y = v - (Dparam.cy);
    
    z = double(Depth); 
    x = (z .* u_x) ./ fx;
    y = (z .* u_y) ./ fy; % 424   512

else 
    f = Dparam.f/Dparam.pixelsize;
    fx = Dparam.fx/Dparam.pixelsize;
    fy = Dparam.fy/Dparam.pixelsize;

    u_x = u - (Dparam.cx);
    u_y = v - (Dparam.cy);

    z = (f .* Depth)./sqrt(f.^2 + u_x.^2 + u_y.^2); 
    x = (z .* u_x) ./ fx;
    y = (z .* u_y) ./ fy; % 480   640
   
end

x = reshape(x, 1, []); % row vector
y = reshape(y, 1, []);
z = reshape(z, 1, []);
X = [x; y; z];

% Plotting
figure; hold on;
scatter3(X(1, :), X(2, :), X(3, :), 10, X(3, :));
colormap jet; colorbar;
scatter3(0, 0, 0, 500, 'gx', 'LineWidth', 2)
title('Task 1: Point cloud in global (x,y,z) space');
set(gca,'YDir','reverse');
set(gca,'ZDir','reverse');
xlabel('X'); ylabel('Y'); zlabel('Z');
axis equal
drawnow;
%% Task 2: Projection to color camera image plane (5 lines of code)

if isKinetic 
    X_proj = R*X + T;
    fx_c = Cparam.fx;
    fy_c = Cparam.fy;

    z_colorcam = X_proj(3,:);
    u_colorcam = fx_c .* X_proj(1,:) ./ z_colorcam + Cparam.cx;
    v_colorcam = fy_c .* X_proj(2,:) ./ z_colorcam + Cparam.cy;

else 
    X_proj = R*X + T;
    fx_c = Cparam.fx/Cparam.pixelsize;
    fy_c = Cparam.fy/Cparam.pixelsize;

    z_colorcam = X_proj(3,:);
    u_colorcam = fx_c .* X_proj(1,:) ./ z_colorcam + Cparam.cx;
    v_colorcam = fy_c .* X_proj(2,:) ./ z_colorcam + Cparam.cy;

end

% Plotting
figure; axis equal
imshow(Image, []); hold on; %#ok<*NODEF>

% Only drawing the objects in front to check alignment
objectmask = z_colorcam<13;
sc = scatter(u_colorcam(objectmask), v_colorcam(objectmask), 10, z_colorcam(objectmask), 'filled');
if isKinetic
    sc = scatter(u_colorcam, v_colorcam, 10, z_colorcam, 'filled');
end
sc.MarkerEdgeAlpha = 0.2;
sc.MarkerFaceAlpha = 0.2;
title( 'Task 2: Global depth points projected on image plane of the color camera');
drawnow;

%% Task 3: Resampling projected data (3 lines of code)

F = scatteredInterpolant(double(u_colorcam(:)), double(v_colorcam(:)), double(z_colorcam(:)), 'nearest');
[u,v] = meshgrid(1:size(Image,2), 1:size(Image,1));   
z_colorcam_reg = F(u,v);
size(z_colorcam_reg);

% Plotting
figure;
subplot( 131); imshow( Image, []); title('Task 3: Original color image')
subplot( 132); imshow( z_colorcam_reg, []); title('Task 3: Resampled depth image');
subplot( 133); imshowpair( Image, z_colorcam_reg); title('Task 3: Resampled depth on original color')

%% Task 4: Visualizing combined depth/color data

% Well, actually, this one is just plotting so you're done already
figure; 
surf(z_colorcam_reg , double(Image), 'EdgeColor', 'none') 
set(gca,'ZDir','reverse');
set(gca,'YDir','reverse');
title( 'Task 4: 3D mesh generated from resampled depth')
drawnow;
 
%% Task 5: Artifact removal (6 lines of code)

if isKinetic  == 0
    % Just plotting here, add your implementation to the edgeRemoval.h function
    figure; 
    h = surf(z_colorcam_reg, double(Image), 'EdgeColor', 'none');
    set(gca,'ZDir','reverse');
    set(gca,'YDir','reverse');
    title( 'Task 5: 3D mesh generated from resampled depth with edge artifacts removed')
    edgeRemoval(h);
end

%% Task 6: Color resampling (4 lines of code)

u_colorcam = reshape(u_colorcam, [size(Depth,1),size(Depth,2)]);
v_colorcam = reshape(v_colorcam, [size(Depth,1),size(Depth,2)]);
z_colorcam = reshape(z_colorcam, [size(Depth,1),size(Depth,2)]);
z = z_colorcam;

r = interp2(u,v, Image(:,:,1), u_colorcam, v_colorcam, "nearest");
g = interp2(u,v, Image(:,:,2), u_colorcam, v_colorcam, "nearest");
b = interp2(u,v, Image(:,:,3), u_colorcam, v_colorcam, "nearest");
resampledColorImage = cat(3, r,g,b); %  480   640     3

% Plotting
figure; 

subplot( 231); imshow( Image, []); title('Task 3: Original color image')
subplot( 232); imshow( z_colorcam_reg, []); title('Task 3: Resampled depth image');
subplot( 233); imshowpair( Image, z_colorcam_reg); title('Task 3: Resampled depth on original color')

subplot( 234); imshow( resampledColorImage, []); title('Task 6: Resampled color image')
subplot( 235); imshow( z, []); title('Task 6: Original depth image');
subplot( 236); imshowpair( resampledColorImage, z); title('Task 6: Resampled color on original depth')
drawnow;


%% Task 7: Z-buffering (19 lines of code)

if isKinetic  == 0

    [u,v] = meshgrid(1:size(Depth,2), 1:size(Depth,1)); 
    uc = u; % depth
    vc = v;
    [idx, ~] = knnsearch([u_colorcam(:), v_colorcam(:)], [u(:), v(:)], 'K', 3);
    z_colorcam =  z_colorcam(:);
    
    z_colorcam_reg_zbuf = zeros(size(u));
    for i=1:size(u_colorcam(:))
        [ ~, idx_temp] = min(z_colorcam(idx(i,:)));
        z_colorcam_reg_zbuf(i) = z_colorcam(idx(i,idx_temp));
    end
    
    z_colorcam_reg_zbuf = reshape(z_colorcam_reg_zbuf, size(u));
    
    % Plotting
    figure;
    subplot(131);
    scatter(u_colorcam(:)', v_colorcam(:)', 10, z_colorcam) 
    ylim([0 size(Depth, 1)]); xlim([0 size(Depth, 2)]); 
    title( 'Irregular'); 
    set(gca,'YDir','reverse'); 
    axis image; 
    drawnow;
    
    subplot(132);
    axis equal
    scatter(uc(:), vc(:), 10, z_colorcam_reg(:))
    ylim([0 size(Depth, 1)]); xlim([0 size(Depth, 2)]);
    title( 'Regular'); 
    set(gca,'YDir','reverse'); 
    axis image; 
    drawnow;
    
    subplot(133);
    axis equal
    scatter(uc(:), vc(:), 10, z_colorcam_reg_zbuf(:))
    ylim([0 size(Depth, 1)]); xlim([0 size(Depth, 2)]);
    title( 'Regular z-buffered');
    set(gca,'YDir','reverse'); 
    axis image; 
    drawnow;
    
    figure; 
    subplot(231); imshow( z_colorcam_reg, []);
    title( 'Task 7: Depth data resampled into a regular grid ');
    subplot(234); imshow( z_colorcam_reg_zbuf, []);
    title( 'Task 7: Depth data resampled into a regular grid after Z-buffering');
    subplot(2, 3, [2 3 5 6]); h = surf(z_colorcam_reg_zbuf, double(Image), 'EdgeColor', 'none');
    set(gca,'ZDir', 'reverse')
    set(gca,'YDir','reverse');
    title( 'Task 7: Z-buffering 3D mesh generated from resampled depth')
    edgeRemoval(h);
    drawnow;
end
%% Task 8: Occlusion handling (14 lines of code)

if isKinetic  == 0
    size(z_colorcam); % 307200           1
    pc = pointCloud([u_colorcam(:), v_colorcam(:), z_colorcam(:)]);
    planeModel = pcfitplane(pc,1);
    plane_params = planeModel.Parameters;
    [idx, d] = knnsearch([u_colorcam(:), v_colorcam(:)], [uc(:), vc(:)], 'K', 1);
    threshold = d > sqrt(1.5); % 1 doesnt really work
    u_missing = uc(threshold);
    v_missing = vc(threshold);
    
    % (au+bv+cz+d=0) 
    % z =-(au+bv+d)/c
    z_missing = -(uc(threshold) * plane_params(1) + vc(threshold) * plane_params(2) + plane_params(4))/plane_params(3);
    z_colorcam_reg_zbuf(threshold)=z_missing;
    z_colorcam_reg_zbuf_filled = z_colorcam_reg_zbuf;
    size(z_colorcam_reg_zbuf_filled) ; %  480   640
    
    % Plotting
    figure;
    scatter3(u_colorcam(:), v_colorcam(:), z_colorcam(:), 10, z_colorcam(:));
    hold on;
    plot(planeModel)
    scatter3(u_missing, v_missing, z_missing, 50, 'gx');
    set(gca,'YDir','reverse');
    set(gca,'ZDir','reverse');
    title('UVZ-point cloud with the plane fit (red) and missing pixels (green)')
    drawnow;
    
    figure; 
    subplot(231); imshow( z_colorcam_reg_zbuf, []);
    title( 'Task 7: Depth data resampled into a regular grid after Z-buffering ');
    subplot(234); imshow( z_colorcam_reg_zbuf_filled, []);
    title( 'Task 7: Depth data resampled into a regular grid after Z-buffering and occlusion filling');
    
    subplot(2, 3, [2 3 5 6]); h = surf(z_colorcam_reg_zbuf_filled, double(Image), 'EdgeColor', 'none');
    set(gca,'ZDir', 'reverse')
    set(gca,'YDir','reverse');
    title( 'Task 8: Z-buffering 3D mesh generated from resampled depth')
    edgeRemoval(h);
    drawnow;
    
end



