% dc

beep off

% simulation
i_x = 1:6;
i_dx = 7:12;
f = @(t,X) [X(i_dx); M(X)^-1*( -C(X)*X(i_dx) -g(X) -spring(X) -0*eye(6)*X(i_dx) )];

% IC
% from tool using chosen eigenmode and unit disk parametrization

% =========================================================================
eigenmode =  eig_rng(1); % CHOOSE HERE MODE INDEX TO SIMULATE
% =========================================================================

%X0 = X{eigenmode}([1,0])';
X0 = [0, -0.0431, 0.1784, 0.2289, 0.0004, 0, 0, 0, 0, 0, 0, 0];
t_end = R{eigenmode}.periods(end) * 1;

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





