% dc

beep off
% % demo_Spatial
% global eig_rng
% eig_rng = 1:6;

% simulation
i_x = 1:6;
i_dx = 7:12;
f = @(t,X) [X(i_dx); M(X)^-1*( -C(X)*X(i_dx) -g(X) -spring(X) -0*eye(6)*X(i_dx) )];

% =========================================================================
eigenmode =  eig_rng( 1 ); % CHOOSE HERE MODE INDEX TO SIMULATE
% =========================================================================
oscillation_repetition = 5;

% IC
X0 = real([R{eigenmode}.generator(end,:), zeros(1,6)]);
t_end = R{eigenmode}.periods(end) * oscillation_repetition;

% 
timespan = linspace(0, t_end, 1e3);

[T_sim, X_sim] = ode113(f, timespan, X0);

% kinetic energy
K_fcn = @(X) 0.5* X(i_dx).'*M(X)*X(i_dx);
% total energy
E_cell = arrayfun(@(uk)V_Grav(uk{:}) + V_Spring(uk{:}) + K_fcn(uk{:}), num2cell(X_sim', 1), 'UniformOutput', false);
E_vec = [E_cell{:}].';

%% animation
LABEL_FONT_SIZE = 18;

play_animation_3D





