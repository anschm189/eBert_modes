function createGravity(robot)
system_base = getenv('DynSystem');
dyn_folder = [system_base, '/matFun'];
if exist(dyn_folder, 'dir') ~= 7
    mkdir(dyn_folder);
    addpath(dyn_folder);
end
disp(" Computing gravitational potential");
nDoF = robot.n_q + 6 * robot.floating;

%% Forward kinematics
qm = sym('q_%d',[nDoF 1],'real');

if robot.floating
    r0 = qm(1:3);
    Euler_Ang=qm(4:6);
    R0 = Angles321_DCM(Euler_Ang)';
    qm = qm(7:end);
else
    r0=sym('r0',[3,1],'real');
    Euler_Ang=sym('Euler_Ang',[3,1],'real');
    R0 = Angles321_DCM(Euler_Ang)';
end

[~,~,~,rL,~,~]=Kinematics(R0,r0,qm,robot);
if robot.floating
    qm = sym('q_%d',[nDoF 1],'real');
else
    rL = subs(rL, [Euler_Ang;r0], zeros(6,1));
end

%% Potential due to gravity
xg = zeros(3,1);
m_full = 0;
for i=1:robot.n_links_joints
    xg = xg + robot.links(i).mass * rL(1:3,i);
    m_full = m_full + robot.links(i).mass;
end
xg = xg / m_full;
xg(4) = m_full;

Vg = -xg(4)*robot.g_vector'*xg(1:3);
digits(5);
Vg = vpa(Vg);

% Vg = simplify(Vg,'Seconds',60);
%% Create Functions
fprintf(' Saving gravitational potential function \n')
matlabFunction(Vg, 'file', [dyn_folder, '/V_Grav'], 'vars', {qm});

g = gradient(Vg, qm); % gravitational forces
disp(" Saving gravitational accelerations vector g");
matlabFunction(g, 'file', [dyn_folder, '/g'], 'vars', {qm});
end

