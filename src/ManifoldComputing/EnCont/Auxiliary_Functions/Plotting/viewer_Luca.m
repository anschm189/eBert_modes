function viewer_Luca(RBig, Gen, Index)
%VIEWER_LUCA Calls viewer for a robot model, given RBig, a generator choice
%and the index of the desired mode. robot_model needs to be given in the
%base workspace as a path to the .urdf for the given robot.

global Simulator;
Simulator = 'Luca';

nDoF = size(RBig,1);
nSearch = nDoF-1;
psi_e_inv = @(u_e,E) project_to_energy(phi2cart(u_e),E);
q0 = psi_e_inv(RBig{Gen,1}(Index,1:nSearch)',RBig{Gen,1}(Index,end));
u0 = [q0; zeros(nDoF,1)];
T = RBig{Gen,2}(Index);
opts = evalin('base','opts');
shoot(u0,T,'Viewer',opts)
end

