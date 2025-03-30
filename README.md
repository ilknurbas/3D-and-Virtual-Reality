# 3D-and-Virtual-Reality
This repository outlines various tasks related to 3D and Virtual Reality, focusing on algorithms and techniques for point cloud registration, camera calibration, 3D data fusion, light field processing, and dense disparity estimation through stereo matching. *Note that some sections of the codes are based on templates provided.*

**`lw1: Implementation of ICP and registering point cloud`**

The objective of this task is to implement the Iterative Closest Point (ICP) algorithm to register two sets of 3D points. It involves visualizing transformed points, estimating the transformation parameters (rotation matrix and translation vector), and applying ICP to align point clouds. Additionally, it includes implementing an adaptive stop criterion for ICP, stitching multiple point clouds, and enhancing the algorithm with color-assisted ICP and point-to-plane metrics to improve accuracy. MATLAB is used for all implementations and visualizations.

**`lw2: Calibration of a multi-camera system and 3D data fusion`**

This task focuses on the calibration of multi-camera systems using range sensors such as the Microsoft Kinect 2.0 and the fusion of captured data to create 3D representations. The aim of the work is to collect calibration data using 2D and 3D calibration objects, perform camera calibration to extract intrinsic and extrinsic parameters, and estimate the relative poses between cameras. Additionally, it involves capturing a static scene and applying the calibration results, processing the data for relevant tasks. The calibration process requires accurate handling of range and color data and careful positioning of the cameras.

**`lw3: Densely Sampled Light Field and Virtual Reality`**

This task is divided into two main sections. The first part focuses on the processing and parameterization of Densely Sampled Light Field (DSLF) data for projection-based light field displays. The goal is to compute and visualize values necessary for light field display setups, including disparities, field of view, and baseline calculations. The second part explores the creation, rendering, and interaction with virtual content within Head-Mounted Displays (HMDs). The task involves capturing 3D models, rendering them in real-time, and integrating them into a virtual environment for a fully immersive experience. Matlab and Unity are used to complete these tasks, with an emphasis on understanding the principles of light field displays and virtual reality content rendering.

**`pp: Dense disparity estimation via local stereo matching`**

The task involves implementing a disparity estimation algorithm through a series of steps. First, the cost function is computed to measure pixel differences between stereo images. Then, the cost is aggregated using methods like box filtering, Gaussian filtering, and local color-weighted filtering. Disparity estimation is carried out using the "Winner-Takes-All" method, which selects the best match for each pixel. Additional tasks, such as detecting occlusions, calculating confidence values for disparity maps, and applying post-filtering techniques to improve the accuracy of the results, are also performed. More advanced tasks, such as implementing cross-bilateral filtering for cost aggregation, are performed as well.
