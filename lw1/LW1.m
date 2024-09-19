% Your implementation should run by executing this m-file ("run LW1.m"), 
% but feel free to create additional files for your own functions
% Make sure it runs without errors after unziping
% This file is for guiding the work. You are free to make changes that suit
% you.

% Fill out the information below

% Group members: Ilknur Bas
% Tasks Completed:   A B C D E F G
% It is advisable to run section by section instead of
% running the whole script.


%% Task A:  Apply transformation on point and visualize  [mandatory]
disp('Task A:');
%create point cloud 
Points=pointCloud([0 0 3; 5 0 5; 2.5 2.5 0]);

%create transformation 
t = [0 2 3];
r = [deg2rad(40) deg2rad(50) deg2rad(20)];

R_x = [1 0 0; 0 cos(r(1)) -sin(r(1)); 0 sin(r(1)) cos(r(1))];
R_y = [cos(r(2)) 0 sin(r(2)); 0 1 0; -sin(r(2)) 0 cos(r(2))];
R_z = [cos(r(3)) -sin(r(3)) 0; sin(r(3)) cos(r(3)) 0; 0 0 1];

R = R_z * R_y * R_x;

PointsMoved = pointCloud(rigidTransform(Points.Location, R, t)); 

%Visualize the point cloud piar
f2=figure;pcshowpair(Points,PointsMoved, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',200)
offset=.2;
hold on, text(Points.Location(:,1)+offset,Points.Location(:,2)+offset ,Points.Location(:,3)+offset,num2str([1:Points.Count]'))
hold on, text(PointsMoved.Location(:,1)+offset, PointsMoved.Location(:,2)+offset ,PointsMoved.Location(:,3)+offset,num2str([1:PointsMoved.Count]'))
hold off

title('Original and Transformed points')
xlabel('X (unit)')
ylabel('Y (unit)')
zlabel('Z (unit)') 

%% Task B: Estimate homogenous transformation [rotation and translation] between original and transformed point cloud of task A [mandatory]
% First run task A to get data for this task B
disp('Task B:');
%data from task A
pts=Points.Location; %reference points
ptsMoved=PointsMoved.Location; % Points to align to reference

% Estimate the transformation [R,t]
[R, t] = estimateRT_pt2pt(pts, ptsMoved);

% Transform 
ptsAlligned = pointCloud(rigidTransform(ptsMoved, R, t)); 

% Visualize
figure,pcshowpair(Points,ptsAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',200)
hold on, text(Points.Location(:,1),Points.Location(:,2) ,Points.Location(:,3),num2str([1:Points.Count]'))
hold on, text(ptsAlligned.Location(:,1), ptsAlligned.Location(:,2) ,ptsAlligned.Location(:,3),num2str([1:ptsAlligned.Count]'))
title('transformed and merged Point clouds')

% Find the error (RMSE)
err = Points.Location - ptsAlligned.Location;
err = err .* err;
err = sum(err(:));
rmse = sqrt(err/ptsAlligned.Count); 
disp(['Task B: Error: ' num2str(rmse)]); % 1.8153e-15

%% Task C: Create a function to iteratively allign bunny ptsMoved point cloud  to the reference [mandatory]
disp('Task C:');  
%load dataset
load('bunny.mat')

% extract points
pts=bunny.Location; %reference points
ptsMoved=bunnyMoved.Location; %Points to align to reference

% Set parameters
DownsampleStep= 0.2; % 0.0015; % can be changed
visualize=true;
iters = 100;
percentage = 0.9;
flag = false;
useColour=false;

%Perform ICP
[bunny_estR,bunny_estt]=ICP(pts, ptsMoved, iters, DownsampleStep, visualize, percentage, [0, 0], flag, useColour, [], [], false, false);

% Visualize Seperately
% bunnyAlligned=pointCloud(rigidTransform(ptsMoved,bunny_estR,bunny_estt));
% figure,pcshowpair(bunny,bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100)

%% Task D: Add an adaptive Stop Criterion to task C [+1]
disp('Task D:'); 
%load dataset
load('bunny.mat')

% extract points
pts=bunny.Location;%reference points
ptsMoved=bunnyMoved.Location; %Points to align to reference

% Set parameters
DownsampleStep=0.2; % 0.0015 can be changed
iters = 200;
tolerance=[0.001, 0.001];  % can be changed
tolerance=[0.001, 0.1];
percentage = 0.9;
visualize=true;
flag = true;
useColour=false;

%Perform ICP
[bunny_estR,bunny_estt]=ICP(pts, ptsMoved, iters, DownsampleStep, visualize, percentage, tolerance, flag, useColour, [], [], false, false);

% Visualize Seperately
% bunnyAlligned=pointCloud(rigidTransform(ptsMoved,bunny_estR,bunny_estt));
% figure,pcshowpair(bunny,bunnyAlligned, 'VerticalAxis','Y', 'VerticalAxisDir', 'down','MarkerSize',100)


%% Task E:	Registration and Stitching of multiple Point Clouds [+1]
disp('Task E:'); 
%load dataset
load('FabLab_scans.mat')

% Set parameters
DownsampleStep= 0.2;
mergeSize=0.03;  %sets the parameter for pcmerge function to merge 2 points if they are assumed to be same.
tolerance= [0.001, 0.001];
visualize=true;  
flag = true;
iters = 100;
percentage = 0.9;
useColour=false;
parte = true;

%visualize first pointcloud 
Map=FabLabm{1};

%open up a figure to display and update
f=figure;
hAxes = pcshow(Map, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
title('Stiched Scene')

% Set the axes property for faster rendering
hAxes.CameraViewAngleMode = 'auto';
hScatter = hAxes.Children;

% To initialize the pipeline
newPtCloud=FabLabm{1};
Rs(:,:,1)=eye(3);
ts(:,1)=[0 0 0]';

for i = 2:length(FabLabm)
       
    % Use previous  point cloud as reference.
    referencePtCloud = newPtCloud;
    
    % get new point cloud which you want to register to the previous point cloud
    newPtCloud = FabLabm{i};
    
    % Apply ICP registration.
    [estR,estt,aligned]=ICP(referencePtCloud.Location, newPtCloud.Location, iters, DownsampleStep,visualize, percentage, tolerance, flag, useColour, [], [], false, parte);
    
    %Accumulate the transformations as shown in Task A and as used inside the ICP function
    Rs(:,:,i) = estR ;
    ts(:,i) = estt;
    
    % Transform the current/new point cloud to the reference coordinate system
    % defined by the first point cloud using the accumulated transformation.  
    size(newPtCloud.Location); %  165956           3
    size(Rs); %    3     3     6
    size(Rs(:,:,i)); % 3     3
    size(ts); %    3     6
    size(ts(:,i)); % 3     1
    size(ts(i)); % 1 1
    length(Rs); % 6
    length(Rs(1)); % 1
     
     
    ptCloudAligned = pointCloud(rigidTransform(newPtCloud.Location, Rs(:,:,i), ts(:,i)'));  
    ptCloudAligned.Color=newPtCloud.Color; 
    
    % Merge the newly alligned point cloud into the global map to update
    Map = pcmerge(  ptCloudAligned,Map,  mergeSize);

    % Visualize the world scene.
    hScatter.XData = Map.Location(:,1);
    hScatter.YData = Map.Location(:,2);
    hScatter.ZData = Map.Location(:,3);
    hScatter.CData = Map.Color;
    drawnow('limitrate')

end
    figure(f)

%% Task F: Create a function to iteratively alligns bunny ptsMoved based on distance and colour [+1]
disp('Task F:'); 
%load dataset
load('slab.mat')

% extract points
pts=slab1.Location;%reference points
ptsMoved=slab2.Location; %Points to align to reference

% Set parameters
DownsampleStep=0.3;
tolerance=[0.001, 0.001];
iters = 100;
flag = true;
percentage = 0.9;

% For testing here, we donot use colour as input. The default distance based ICP is used
visualize=false;
useColour=false;
[slab_estR,slab_estt]=ICP(pts,ptsMoved, iters, DownsampleStep, visualize, percentage, tolerance, flag, useColour, slab1, slab2, false, false); % colour input only used for visualization


% Use colour assisted ICP
useColour=true;
visualize=false;
[slab_estR,slab_estt]=ICP(pts,ptsMoved, iters, DownsampleStep, visualize, percentage, tolerance, flag, useColour, slab1, slab2, false, false); % colour used both for visualization and estimation

% i) Pro and cons of ICP vs other registrations methods 
% Cons
% ICP is easy to implement.
% Cons
% ** Initial alignment might matter in terms of convergence.
% ** It is sensitive to outliers, missing data points etc.

% ii) How to make ICP robust to noise.
% ** We could try to implement point-2-plane
% ** We could come up with an efficient algorithm where it can find optimal
% initial alignment.
% ** We could come up with an algorithm where we reject outliers in the
% point cloud.

%% Task G: Create a function to iteratively allign  bunny ptsMoved using point-2-plane metric [+1]
%load dataset
load('bunny.mat')
disp('Task G:'); 
% extract points
pts=bunny.Location;%reference points
ptsMoved=bunnyMoved.Location; %Points to align to reference

% Set parameters
tolerance=[0.001, 0.001];
DownsampleStep=0.15;
useColour=false;
visualize=true;
flag = true;
percentage = 0.9;
iters = 100;

% compare the convergence both metrics in terms of iterations and final error
% point-to-point method
[bunny_estR,bunny_estt,bunnyAlligned]=ICP(pts,ptsMoved, iters, DownsampleStep, visualize, percentage, tolerance, flag, useColour, [], [], false, false); 
err = pts - bunnyAlligned.Location;
err = err .* err;
err = sum(err(:));
rmse = sqrt(err/bunnyAlligned.Count);  
disp(['Task G: Error point-to-point method: ' num2str(rmse)]);  % 0.00061041
%%
partg = true;
% point-to-plane method
[bunny_estR,bunny_estt,bunnyAlligned]=ICP(pts,ptsMoved, iters, DownsampleStep, visualize, percentage, tolerance, flag, useColour, [], [], partg,false); 

err = pts - bunnyAlligned.Location;
err = err .* err;
err = sum(err(:));
rmse = sqrt(err/bunnyAlligned.Count);
disp(['Task G: Error point-to-plane method: ' num2str(rmse)]);  % 0.058946

% Comment on the difference in performance of point-to-point and point-to-plane error metric.
% Point-to-plane is computationally more expensive as it involves more
% computation, calculating normals etc. Thats why I would expect this metric to give
% less error and more robust alignment. But i got higher error.

