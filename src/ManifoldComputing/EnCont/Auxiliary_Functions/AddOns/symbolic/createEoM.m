function createEoM(robot)
system_base = getenv('DynSystem');
dyn_folder = [system_base, '/matFun'];
if exist(dyn_folder, 'dir') ~= 7
    mkdir(dyn_folder);
    addpath(dyn_folder);
end
disp("  Computing equations of motion");
nDoF = robot.dof;
q = sym('q_%d',[nDoF 1],'real');
dq = sym('dq_%d',[nDoF 1],'real');

%% get dynamics
[M, C, V_Grav] = dynamics(q, dq);

V_Grav = -V_Grav; % Yannicks definition is negative
g = gradient(V_Grav, q);

%% Create Functions
fprintf('    Creating gravitational potential function \n')
matlabFunction(V_Grav, 'file', [dyn_folder, '/V_Grav'], 'vars', {q});
disp("    Creating gravitational accelerations vector g");
matlabFunction(g, 'file', [dyn_folder, '/g'], 'vars', {q});
disp("    Creating mass matrix M");
matlabFunction(M, 'file', [dyn_folder, '/M'], 'vars', {q});
disp("    Creating coriolis and zentrifugal matrix C");
matlabFunction(C, 'file', [dyn_folder, '/C'], 'vars', {[q;dq]});
end