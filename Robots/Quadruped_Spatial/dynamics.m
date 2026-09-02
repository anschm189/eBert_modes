function [M, C, V_Grav] = dynamics(q, dq)
%M Summary of this function goes here
%   M*ddq + C*dq + dV_Grav/dq

% q: coordinate system after substitution by IK

% extract mass matrix wrt body, no leg mass
disp('Loading robot..')
urdf_file = [getenv('MANIAC_BASE') '/Robots/Quadruped_Spatial/models/etnabert_no_legs_plus.urdf'];
robot = create_robot_from_urdf(urdf_file);
disp('Running LD..')
[xg_ld,~,M_ld,~,~,~,~,~,~,~,~] = KaneScrew( 0, 1, robot.parent, robot.g0, robot.csi, robot.com, robot.Mass, q, dq);

m = xg_ld(4);
M_ld(1:3,1:3) = m*eye(3);

% dynamics simplification
addpath(getenv('CORA_BASE'))
    M_vpa = vpa(M_ld, 5);
    disp('Pruning Mass Matrix..')
    M_1 = simplify_remove_epsilon_terms(M_vpa.', 1e-10, q, false).';
    disp('Simplifing Mass Matrix..')
    M = simplify_remove_epsilon_terms(M_1.', 1e-10, q, true).';
    disp('Gyroscopic..')
    C = simplify(get_Gyroscopic_via_Christoffel(M, q, dq));
    % TODO: check C == C_ld
    % center of mass
    disp('COM..')
%     xg_vpa = vpa(xg_ld, 5);
%     xg_pruned = simplify_remove_epsilon_terms(xg_vpa.', 1e-10, q, false).';
%     xg = simplify_remove_epsilon_terms(xg_pruned.', 1e-10, q, false).';
rmpath(getenv('CORA_BASE'))

V_Grav = -9.81*m*xg_ld(3);

end