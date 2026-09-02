function [ EPot ] = V( u, E )
%POTENTIAL Potential function using E as the reference for the 0-Level
%   V(u,0) is the potential energy of the robot_model defined in StartUp 
%   or StartUp_Simulink, which is here split into spring terms and gravity.
%   After x_eq was found as a local minimum of V(u,0), and is stored in 
%   the base space, the equilibrium satisfies V(x_eq,0) = 0.
%   Further, V(u,E) = V(u,0) - E;

global x_eq;
u_eq = x_eq;
%% Main Calculations
 EPot = @(u) V_Grav(u) + V_Spring(u);
 EPot = EPot(u) - EPot(u_eq) - E;
end

