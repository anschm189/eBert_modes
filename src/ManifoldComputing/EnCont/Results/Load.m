%% Choose saved data for RBig of previous system
% clearvars;
% close all;
warning('off'); rmpath(genpath(fullfile('..','Specific_Systems'))); warning('on');
addpath(genpath(fullfile('..','Auxiliary_Functions')));
addpath((fullfile('..','Specific_Systems/Luca')));                          % Change this to the appropriate specific system
data = load('RBig_LBR_k10_20J.mat');                                        % Change this to load a new file
StartUp;
nSearch = nDoF-1;

%% Required Functions:
opts = odeset('RelTol',1e-9,'AbsTol',1e-9);                                 % Tolerance of ODE Solver
global x_eq;
x_eq = fminsearch(@(u)V(u,0),zeros(nDoF,1));  
psi_inv = @(u_red) [u_red; zeros(nDoF,1)];                                  % Transformation from configuration to state space 
psi_e_inv = @(u_e,E) project_to_energy(phi2cart(u_e),E);                    % Transformation from energy shell centered on Equilibrium to configuration 

%% Processing
RBig = data.RBig;
% plotPeriod;
% Y = store_modes(RBig,nDoF,nSearch,@(u,E)psi_inv(psi_e_inv(u,E)),opts);
% nDoF_GUI;


