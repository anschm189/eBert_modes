# eBert_modes
Code to calculate and visualize modes of the quadruped eBert.

## Overview

This is the accompanying repository for the paper "Exploring Nonlinear Body Oscillations for Natural Quadruped Gaits". The repository contains:
the code to show the nonlinear normal modes of the elastic quadruped eBert

The underlying continuation algorithm was developed in previous work by Yannik P. Wotte, Filip Bjelonic, Arne Sachtler, and Cosimo Della Santina. The quadruped model for the paper was developed by Davide Calzolari. Below you can find instruction on how to use the algorithm in combination with the quadruped model.

The code shows for eBert 

- a discrete set of points (called point cloud) describing all the generators R that are available in a robotic system,
- the evolution of each point of the generator (eigenmode evolutions), which creates a point cloud representation of the corresponding eigenmanifold M together with a state space triangular mesh of the point cloud

## Instructions
Start MATLAB and initialize the tool by running `setup.m`. <br>
Run `set_environment_bert.m`. <br>

### Elastic Quadruped eBert 
To show the 6 nonlinear modes of the elastic quadruped eBert, please run the following scripts in order.

1. Run `Robots/Quadruped_Spatial/plot_proj_eigenmanifold.m` to visualize projections of the first two Eigenmanifolds.<br>
2. Use `Robots/Quadruped_Spatial/AnimateMode.m` to visualize a 3D animation of the quadruped performing the nonlinear oscillation. The index in line 14: `eigenmode =  eig_rng(1);` can be changed to visualize a different mode, from `1` to `6`. <br>

## Toolbox Requirements
MATLAB (with Statistic, Machine Learning, Symbolic Math, Optimization, and Signal Processing Toolboxes).
The code was tested on MATLAB 2018b.

## References of previous works in the process of developing the toolbox

Bjelonic, F., Sachtler, A., Albu-Schäffer, A., & Della Santina, C. (2022). Experimental closed-loop excitation of nonlinear normal modes on an elastic industrial robot. IEEE Robotics and Automation Letters, 7(2), 1689-1696.

Coelho, A., Albu-Schaeffer, A., Sachtler, A., Mishra, H., Bicego, D., Ott, C., & Franchi, A. (2022, December). EigenMPC: An eigenmanifold-inspired model-predictive control framework for exciting efficient oscillations in mechanical systems. In 2022 IEEE 61st Conference on Decision and Control (CDC) (pp. 2437-2442). IEEE.


