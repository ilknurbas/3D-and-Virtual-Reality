% Ilknur Bas Group 28
% In this demo: 
% - left-to-right correspondance check
% - confidence analysis
% - outlier filling 
% - Bilateral aggregation

clear all;
close all;
clc;

dataset = '../teddy'; factor = 4;

L = imread([dataset,'/view1.png']);
R = imread([dataset,'/view5.png']);
GTL = round(single(imread([dataset,'/disp1.png']))./factor);
GTR = round(single(imread([dataset,'/disp5.png']))./factor);

mindisp = 0;
maxdisp = ceil(max(GTL(:)));


% Computing costs and disparity maps in the same way as in 
% the mandatory steps for analysis
smoothingAmount = 100;
radius = 11;

[CostL, CostR] = calculate_cost(L, R, maxdisp);
guidedCostL = aggregate_cost_guided(CostL, L, radius, smoothingAmount);
guidedCostR = aggregate_cost_guided(CostR, R, radius, smoothingAmount);

[DispLeftGuided] = winner_takes_all(guidedCostL);
[DispRightGuided] = winner_takes_all(guidedCostR); 

h = figure; subplot(3, 2, 1);
imshow(DispLeftGuided, [0 maxdisp]); title([ 'Raw disparity from guided filter, error: ', num2str(calculate_error(DispLeftGuided, GTL))]);  drawnow;
%% Left-to-Right correspondance check
%[DispLeftGuided] = winner_takes_all(GTL);
%[DispRightGuided] = winner_takes_all(GTR);

[outliersL, outliersR] = consistency_check(DispLeftGuided, DispRightGuided, 1);
figure(h); subplot(3, 2, 2); imshow(outliersL, [0 1]); title('Left outliers'); drawnow;

%% Confidence analysis
ConfL = comp_confidence(guidedCostL);
figure(h); subplot(3, 2, 3); imshow(ConfL, [0 1]); title('Confidence map of the left view');  drawnow;
    

%% Outlier Filling
DispLeftGuided_filled = fill_blanks(DispLeftGuided, outliersL, ConfL);
figure(h); subplot(3, 2, 4); imshow(DispLeftGuided_filled, [mindisp maxdisp]); 
title([ 'Outlier compensated left disparity, error: ', num2str(calculate_error(DispLeftGuided_filled, GTL))]);  drawnow;


%% Bilateral aggregation
% msgbox('No demo code available yet. Compare the result with the one from guided filter, they should produce similar results', 'Bilateral filtering');

bilateralCostL = aggregate_cost_bilateral(CostL, L, radius);
[DispLeftBilateral] = winner_takes_all(bilateralCostL);
figure(h); subplot(3, 2, 5:6);
imshow(DispLeftBilateral, [0 maxdisp]); title([ 'Raw disparity from bilateral filter, error: ', num2str(calculate_error(DispLeftBilateral, GTL))]); 

