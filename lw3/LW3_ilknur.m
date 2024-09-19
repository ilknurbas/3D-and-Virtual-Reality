%--------------------------------------------------------------------------
% COMP.SGN.320 3D and Virtual Reality
%   
% Your implementation should run by executing this m-file ("run LW3.m"), 
% but feel free to create additional files for your own functions
% Make sure it runs without errors after unzipping
%
% Fill out the information below
%
% Group members: Ilknur Bas
% Completed tasks: All
%
%--------------------------------------------------------------------------
clc; clear all; close all;

% Global options
DEBUG = 1;
OPENGL = 1; % Device backend (OpenGL vs. MATLAB Painters)
ANTIALIASING = 1; % Apply antialiasing filter
DISPLAYPOINTCLOUD = 0; % Draw mesh or point cloud (for "3DView" window)
WIN_WIDTH = 800; % Window width (for "3DView" window)
WIN_HEIGHT = 600; % Window height (for "3DView" window)
SAVEDATA = 0; % Save rendered data
SHOW_AXIS_RENDERINGVIEW = 0; % Show axis(for "RenderingView" window)
BACKGROUND_COLOR = [0.5,0.5,0.5]; % Change background color of rendered scene

% Computed parameters
SX = 1920; % Camera horizontal resolution
SY = 1080; % Camera vertical resolution
ZMIN = 2.75; % Minimum distance from camera to scene
ZMAX = 3.25; % Maximum distance from camera to scene
XSCENE = 1.56; % Width of the scene
BASELINE = 2; % Baseline

% Libraries and assets
addpath('./RenderingPipeline/'); % Mini lib to help with the rendering pipeline and virtual content
addpath('./ply/'); % Folder with (ASCII) .ply assets
%% (DO NOT EDIT)-----------------------------------------------------------
FULLSCREEN = 0; % Fullscreen window
RENDER_CAM_WIDTH = SX; % Window width (for "RenderingView" viewport) 
RENDER_CAM_HEIGHT = SY; % Window height (for "RenderingView" viewport) 
% Create main window(s)
if(OPENGL)
    wh1 = Window(WIN_WIDTH, WIN_HEIGHT, '3DView', FULLSCREEN, 'opengl', ANTIALIASING);
    wh2 = Window(RENDER_CAM_WIDTH, RENDER_CAM_HEIGHT, 'RenderingView', FULLSCREEN, 'opengl', ANTIALIASING);
else
    wh1 = Window(WIN_WIDTH, WIN_HEIGHT, '3DView', FULLSCREEN, 'painters', ANTIALIASING);
    wh2 = Window(RENDER_CAM_WIDTH, RENDER_CAM_HEIGHT, 'RenderingView', FULLSCREEN, 'painters', ANTIALIASING);
end
%%-------------------------------------------------------------------------
%% Create virtual content - Task 3.2

% Example using the "RenderingPipeline" lib:
% Create default (empty) scene:
sceneObj = Scene();

% Create a custom mesh:
mesh1 = Object3D();

% Define properties for custom mesh:
% Name
mesh1.Name = 'My custom mesh';

% Vertices
% mesh1.XYZ = [V1X V2X V3X V4X ..; ... %X
%              V1Y V2Y V3Y V4Y ..; ... %Y
%              V1Z V2Z V3Z V4Z ..];   %Z  
v1 = [0, 0, 0];
v2 = [2, 0, 0];
v3 = [2, 2, 0];
v4 = [0, 2, 0];
v5 = [0, 0, 2];
v6 = [2, 0, 2];
v7 = [2, 2, 2];
v8 = [0, 2, 2];

vertices = ([v1;v2;v3;v4;v5;v6;v7;v8])';
size(vertices);  % 3x8
mesh1.XYZ =  vertices; 

% Number of vertices
mesh1.VerticesCount = size(mesh1.XYZ, 2);

% Vertices color
R = [0.3, 0.2, 0.4, 0.0, 0.2, 0.1, 0.8, 0.2];
G = [0.2, 0.8, 0.5, 0.4, 0.4, 0.3, 0.2, 0.4];
B = [0.3, 0.1, 0.2, 0.9, 0.9, 0.6, 0.3, 0.6];
A = [1.0, 0.7, 0.8, 0.0, 0.2, 0.9, 0.2, 0.9];

mesh1.VerticesColor = [R; G; B; A];
% mesh1.VerticesColor = [RV1 RV2 RV3 RV4 ..; ... %R
%                       GV1 GV2 GV3 GV4 ..; ... %G
%                       BV1 BV2 BV3 BV4 ..; ... %B
%                       AV1 AV2 AV3 AV4 ..];    %A

% List of triangle connections
% mesh1.TriangleNodes = [1  6  7  ..; ... 
%                        2  5  3  ..; ...
%                        3  8  2  ..]; 
connections = [1, 6, 2; % bottom face
               1, 5, 6; % bottom 
               6, 3, 2; % right
               6, 7, 3; % right
               3, 8, 7; % upper
               3, 4, 8; % upper
               4, 1, 5; % left
               4, 8, 5; % left
               1, 2, 3; % front
               1, 3, 4; % front
               5, 6, 7; % back  
               5, 7, 8  % back
               ]; 

mesh1.TriangleNodes = connections'; %    3    12

% Triangle number   #1  #2  #3  #4  #5  #6  #7  #8  #9  #10
% mesh1.FacesColor = [RF1   RF2   RF3   RF4   ..; ... %R
%                     GF1   GF2   GF3   GF4   ..; ... %G
%                     BF1   BF2   BF3   BF4   ..; ... %B
%                     AF1   AF2   AF3   AF4   ..];    %A

% Triangle number   #1  #2  #3  #4  #5  #6  #7  #8  #9  #10
mesh1.FacesColor = [1   0   0   1   1   1   0.7   0.2   0.5   0.5 0.3   0.3;  %R
                    0   1   0   1   0   1   0.4   0.6   0.3   0.3 0.7   0.4;  %G
                    0   0   1   0   1   1   0.3   0.3   0.7   0.4 0.5   0.5;  %B
                    1.0 1.0 1.0 1.0 1.0 1.0 1.0   1.0   1.0   1.0 1.0   1.0  %A
                    ]; 

% Number of faces
mesh1.FacesCount = size(mesh1.FacesColor, 2);

% Set material
mesh1.Material.SetMaterial(0.3, 0.3, 1.0, 25, 0.5);

% Apply some transformations: 
mesh1 = mesh1.SetScale([0.15, 0.15, 0.15]);
mesh1 = mesh1.SetPosition([0.2, 0, 2.85]);

% Add custom object to sceneObj:
sceneObj = sceneObj.AddObject3D(mesh1);

% Create 3D object from ply file:
mesh2 = Object3D('pyramid');

% Apply some changes to mesh2: 
%mesh2 = mesh2.SetScale([0.1, 1, 0.5]);
mesh2 = mesh2.SetScale([0.25, 0.25, 0.5]);
mesh2 = mesh2.SetPosition([0.0, -0.25, 3.0]); % ADDED NEW

% mesh2 = mesh2.SetFacesColor([RF1   RF2   RF3   RF4   ..; ... %R
%                              GF1   GF2   GF3   GF4   ..; ... %G
%                              BF1   BF2   BF3   BF4   ..; ... %B
%                              AF1   AF2   AF3   AF4   ..]);   %A

facecolors = [
    1.0, 0.0, 0.0, 1.0; % f1
    0.0, 1.0, 0.0, 1.0; % f2
    0.0, 0.0, 1.0, 1.0; % f3
    1.0, 1.0, 0.0, 1.0; % f4
    0.0, 1.0, 1.0, 1.0; % f5
    0.4, 0.2, 0.5, 1.0  % f6
];

mesh2 = mesh2.SetFacesColor(facecolors); 

% sceneObj = sceneObj.AddObject3D(mesh1);
sceneObj = sceneObj.AddObject3D(mesh2);

% Change navigation camera view (3DView window)
sceneObj = sceneObj.SetNavigationCameraDirection(10, -145);

% Set main camera properties
sceneObj.MainCamera.FoV = rad2deg(2 * atan((BASELINE + XSCENE) /(2 * ZMIN))); % ??; 
sceneObj.MainCamera.ResX = SX;
sceneObj.MainCamera.ResY = SY;
sceneObj.MainCamera.Position = [BASELINE/2, 0, 0];

% Change light(s) attributes
sceneObj.ListOfLightSources{1}.Type = 'local';
sceneObj.ListOfLightSources{1}.Position = [0.5, 0.5, 1];

%Preview 3D model(s)
figure(1), cla;
for i=1:length(sceneObj.ListOfObjects3D)
    hold on;
    for c = 1:size(sceneObj.ListOfObjects3D{i}.TriangleNodes, 2)
        XYZVertices = sceneObj.ListOfObjects3D{i}.XYZ;
        XYZVertices = XYZVertices([3 1 2], :); %Reoreder rows because of Patch
        patch('Faces', [1 2 3], ...
            'Vertices', [XYZVertices(:,sceneObj.ListOfObjects3D{i}.TriangleNodes(3, c)), ...
            XYZVertices(:,sceneObj.ListOfObjects3D{i}.TriangleNodes(1, c)), ...
            XYZVertices(:,sceneObj.ListOfObjects3D{i}.TriangleNodes(2, c))]', ...
            'FaceColor', sceneObj.ListOfObjects3D{i}.FacesColor(1:3,c), ...
            'FaceAlpha', sceneObj.ListOfObjects3D{i}.FacesColor(4,c), ...
            'EdgeColor', 'none');
    end
end
hold off;
axis equal;
grid on;
xlabel('Z [m]'), ylabel('X [m]'), zlabel('Y [m]');
% xlim([0, 5]); % Fix z limit
% ylim([-1, 1]); % Fix x limit
% zlim([-1, 1]); % Fix y limit
view(-145, 10);


%% Render content - Task 3.3

% Compute camera intrinsics
fx = SX * cot(deg2rad( sceneObj.MainCamera.FoV/2))/2 ;% 100; %?;
fy = fx; % square pixel
cx = SX/2; % 960; %?; 
cy = SY/2; % 540 %?;
% Camera matrix:
K = [fx, 0, cx; 0, fy, cy; 0, 0, 1];

% Compute capturing system variables
numberOfViews = 167 ; %?;
adjacentViewDistance = BASELINE/(numberOfViews-1); %?; %meters


for k=1:numberOfViews
  
%% (DO NOT EDIT)-----------------------------------------------------------
    % Show 3D Scene 
    set(0,'CurrentFigure',wh1);
    sceneObj.RenderScene(DISPLAYPOINTCLOUD, DEBUG);
    axis on;
    xlim([-1, ZMAX + 1]); % Fix z limit
    ylim([-1.5, 1.5]); % Fix x limit
    zlim([-1.5, 1.5]); % Fix y limit
    
    % Show Render
    set(0,'CurrentFigure',wh2); % Activate XRView window
    cla; % Clear content
    ax = wh2.CurrentAxes; % Get handle to current axes and change some attributes
    ax.Color = BACKGROUND_COLOR;
    ax.GridColor = 'w';
    ax.XColor = 'w';
    ax.YColor = 'w';
    ax.ZColor = 'w';
    ax.Box = 'on';
    xlabel('u (pixels)');
    ylabel('v (pixels)');
    hold on;
%%-------------------------------------------------------------------------
   
    % Draw virtual content:
    R =  sceneObj.MainCamera.Orientation'; % ?;
    size(R);
    size(sceneObj.MainCamera.Position');
    T = - R * sceneObj.MainCamera.Position';
    size(T)
    for i=1:length(sceneObj.ListOfObjects3D)
        uv = Project3DTo2D(K, [-1 0 0; 0 -1 0; 0 0 1] * (R * sceneObj.ListOfObjects3D{i}.XYZ + T));
        uv(3,:) = sceneObj.ListOfObjects3D{i}.XYZ(3,:);

        for c = 1:size(sceneObj.ListOfObjects3D{i}.TriangleNodes, 2)
            handles.pathHAndle{i,c} = patch('Faces', [1 2 3], ...
                'Vertices', [uv(:,sceneObj.ListOfObjects3D{i}.TriangleNodes(1, c)), ...
                uv(:,sceneObj.ListOfObjects3D{i}.TriangleNodes(2, c)), ...
                uv(:,sceneObj.ListOfObjects3D{i}.TriangleNodes(3, c))]', ...
                'FaceColor', sceneObj.ListOfObjects3D{i}.FacesColor(1:3,c), ...
                'FaceAlpha', sceneObj.ListOfObjects3D{i}.FacesColor(4,c), ...
                'EdgeColor', 'none');
        end
    end

%% (DO NOT EDIT)-----------------------------------------------------------
    % "Render" light source:
    lt = light(wh2.CurrentAxes);
    lt.Color = sceneObj.ListOfLightSources{1}.Color;
    lt.Style = sceneObj.ListOfLightSources{1}.Type;
    lt.Position = [sceneObj.ListOfLightSources{1}.Position(3), ...
                   sceneObj.ListOfLightSources{1}.Position(1), ...
                   sceneObj.ListOfLightSources{1}.Position(2)];

    hold off;
    axis on;
    if(~SHOW_AXIS_RENDERINGVIEW)
        set(wh2.CurrentAxes,'xtick',[]);
        set(wh2.CurrentAxes,'ytick',[]);
        wh2.CurrentAxes.Box = 'off';
        set(wh2.CurrentAxes, 'XLabel', []);
        set(wh2.CurrentAxes, 'YLabel', []);
        set(wh2.CurrentAxes, 'XTickLabel', []);
        set(wh2.CurrentAxes, 'YTickLabel', []);
        set(wh2.CurrentAxes, 'XColor', BACKGROUND_COLOR);
        set(wh2.CurrentAxes, 'YColor', BACKGROUND_COLOR);
        set(wh2.CurrentAxes, 'ZColor', BACKGROUND_COLOR);
    end

    set(gca, 'ZDir','reverse'); % fix axis direction Matlab plot
    set(gca,'YDir','reverse'); % fix axis direction Matlab plot
    xlim([1, sceneObj.MainCamera.ResX]); % camera resolution width
    ylim([1, sceneObj.MainCamera.ResY]); % camera resolution height
    zlim([0.01, 5]); % camera near / far clip 
    pbaspect([1, sceneObj.MainCamera.ResY/sceneObj.MainCamera.ResX, 1]); % fix aspect ratio of axis box 
    
    drawnow();
    
    % Save image
    if (SAVEDATA)
        set(wh2.CurrentAxes,'xtick',[]);
        set(wh2.CurrentAxes,'ytick',[]);
        wh2.CurrentAxes.Box = 'off';
        set(wh2.CurrentAxes, 'XLabel', []);
        set(wh2.CurrentAxes, 'YLabel', []);
        set(wh2.CurrentAxes, 'XTickLabel', []);
        set(wh2.CurrentAxes, 'YTickLabel', []);
        set(wh2.CurrentAxes, 'XColor', BACKGROUND_COLOR);
        set(wh2.CurrentAxes, 'YColor', BACKGROUND_COLOR);
        set(wh2.CurrentAxes, 'ZColor', BACKGROUND_COLOR);
        imgNo = pad(num2str(k),4,'left','0');
        nameFig = strcat('image_',imgNo,'.png');
        sceneObj.SaveRenderedImage(wh2.CurrentAxes, nameFig);
    end
    
    % Move Camera
    sceneObj.MainCamera.Position = ...
        [sceneObj.MainCamera.Position(1) - adjacentViewDistance, ...
         sceneObj.MainCamera.Position(2), ...
         sceneObj.MainCamera.Position(3)];
 %%------------------------------------------------------------------------

end

%--------------------------------------------------------------------------
% Functions
%--------------------------------------------------------------------------
function uv = Project3DTo2D(K, xyz)
% INPUT:
% K - Camera matrix (intrinsic parameters)
% xyz - 3D points
size(K);
size(xyz);
coords = K * xyz;
uv = coords(1:2, :) ./ coords(3, :);% Normalize

% OUTPUT:
% uv - 2D points
end