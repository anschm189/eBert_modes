%% StartUp gives general system information

global Simulator;
Simulator = "Standard";
nDoF = 6;

global K xb0
K = ones(12,1)*6.5;
K([1 4 7 10]) = 13;

xb0 = [0.0; 0; 0.211; 0];

%% Initialize the dynamics functions
InitDynamics;

%% Initialize the equilibrium position close enough, if specific equilibrium is desired
global x_eq;
x_eq = [0;0;0.2;0;0;0];



