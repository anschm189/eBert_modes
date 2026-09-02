function [xg, M, C] = robotDynamics(robot, qm, um)
%% get robot mass matrix, coriolis matrix and center of mass
%% Kinematics
%Base-link position
% r0=sym('r0',[3,1],'real');
if robot.floating
    r0 = qm(1:3);
    Euler_Ang=qm(4:6);
    R0 = Angles321_DCM(Euler_Ang)';
    qm = qm(7:end);
    u0 = um(1:6);
    um = um(7:end);
else
    r0=sym('r0',[3,1],'real');
    Euler_Ang=sym('Euler_Ang',[3,1],'real');
    R0 = Angles321_DCM(Euler_Ang)';
    u0=sym('u0',[6,1],'real');
end

[~,RL,~,rL,e,g]=Kinematics(R0,r0,qm,robot);
[Bij,Bi0,P0,pm]=DiffKinematics(R0,r0,rL,e,g,robot);

%Twist (operational-space velocities)
[t0,tL]=Velocities(Bij,Bi0,P0,pm,u0,um,robot);

%% Dynamics
%Twist (operational-space velocities)
[I0,Im]=I_I(R0,RL,robot);
[M0_tilde,Mm_tilde]=MCB(I0,Im,Bij,Bi0,robot);
[H0, H0m, Hm] = GIM(M0_tilde,Mm_tilde,Bij,Bi0,P0,pm,robot);
[C0, C0m, Cm0, Cm] = CIM(t0,tL,I0,Im,M0_tilde,Mm_tilde,Bij,Bi0,P0,pm,robot);
if robot.floating
    M = [H0, H0m; H0m', Hm];
    C = [C0, C0m; Cm0, Cm];
else
    Hm = subs(Hm, [Euler_Ang;r0;u0], zeros(12,1));
    Cm = subs(Cm, [Euler_Ang;r0;u0], zeros(12,1));
    M = Hm;
    C = Cm;
    rL = subs(rL, [Euler_Ang;r0;u0], zeros(12,1));
end
xg = zeros(3,1);
m_full = 0;
for i=1:robot.n_links_joints
    xg = xg + robot.links(i).mass * rL(1:3,i);
    m_full = m_full + robot.links(i).mass;
end
xg = xg / m_full;
xg(4) = m_full;
end