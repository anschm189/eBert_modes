function du = EoM(u, T)
%% get robot mass matrix, coriolis matrix and center of mass
%% Kinematics
%Base-link position
qm = u(1:end/2);
um = u(end/2+1:end);
load('robot.mat', 'robot');
% r0=sym('r0',[3,1],'real');
if robot.floating
    r0 = qm(1:3);
    Euler_Ang=qm(4:6);
    R0 = Angles321_DCM(Euler_Ang)';
    qm = qm(7:end);
    u0 = um(1:6);
    um = um(7:end);
else
    r0=zeros(3,1);
    Euler_Ang=zeros(3,1);
    R0 = Angles321_DCM(Euler_Ang)';
    u0=zeros(6,1);
end

[~,RL,~,rL,e,gs]=Kinematics(R0,r0,qm,robot);
[Bij,Bi0,P0,pm]=DiffKinematics(R0,r0,rL,e,gs,robot);

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
    qm = u(1:end/2);
    um = u(end/2+1:end);
else
    M = Hm;
    C = Cm;
end
g_ = g(qm);
pot = spring(qm);
ddq = -M \ (C * um + pot + g_);
du = T*[um;ddq];
end