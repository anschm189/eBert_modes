function createEoM_urdf(robot, gravity_only)
system_base = getenv('DynSystem');
dyn_folder = [system_base, '/matFun'];
if exist(dyn_folder, 'dir') ~= 7
    mkdir(dyn_folder);
    addpath(dyn_folder);
end
disp("  Computing equations of motion");
nDoF = robot.n_q + 6 * robot.floating;
q = sym('q_%d',[nDoF 1],'real');
dq = sym('dq_%d',[nDoF 1],'real');

%% get dynamics
tic;
[xg, M, C] = robotDynamics(robot, q, dq);
disp(toc);
tic;
Vg = -xg(4)*robot.g_vector'*xg(1:3);
digits(5);
Vg = vpa(Vg);

%% Simplify expressions
Vg = simplify(Vg,'Seconds',60);
%% Create Functions
fprintf(' Saving gravitational potential function \n')
matlabFunction(Vg, 'file', [dyn_folder, '/V_Grav'], 'vars', {q});

g = gradient(Vg, q);
disp("    Saving gravitational accelerations vector g");
matlabFunction(g, 'file', [dyn_folder, '/g'], 'vars', {q});
if gravity_only
   return;
end
fprintf('    This took %4.2f Seconds \n', toc);
tic;
disp("    Saving mass matrix M");
matlabFunction(M, 'file', [dyn_folder, '/M'], 'vars', {q});
fprintf('    This took %4.2f Seconds \n', toc);
tic;
disp("    Saving coriolis and zentrifugal matrix C");
matlabFunction(C, 'file', [dyn_folder, '/C'], 'vars', {[q;dq]});
fprintf('    This took %4.2f Seconds \n', toc);
end