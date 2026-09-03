base = getenv('ENCONT_BASE');
maniac_base = getenv('MANIAC_BASE');

selected_system = 'Quadruped_Spatial';

%% 0.1 Initial definitions: System
setenv('DynSystem', [maniac_base, '/Robots/', selected_system]);
setenv('SaveFiles', [base, '/Mat_Files']);
warning('off'); rmpath(genpath([maniac_base, '/Robots']));
warning('on');
addpath(genpath([maniac_base, '/Robots/', selected_system]));

StartUp;         
% Loads System, determines nDoF and Simulator
if exist('numeric', 'var') == 0 % if variable does not exist, the robot dynamics are already provided
    warning('off'); 
    rmpath(genpath([base, '/Auxiliary_Functions/AddOns/numeric'])); 
    addpath(genpath([base, '/Auxiliary_Functions/AddOns/symbolic']));
    warning('on');
end

max_time = 86400; % 24h per generator

Err_min = 1.0000e-03;
nS_2 = 1;
nDoF = 6;
nSearch = nDoF - 1;                                                         
dim_u = 2*nDoF;                                                             
dim_uS = [nSearch;ones(nS_2-1,1)*dim_u; nSearch];                           
nMax = 4*nDoF;                                                              
opts = odeset('RelTol',Err_min*1e-3,'AbsTol',Err_min*1e-3);                 
opts_fsolve = optimoptions(@fsolve,...
    'FunctionTolerance', Err_min*1e-2,'OptimalityTolerance', Err_min*1e-2, ... 
    'Algorithm', 'trust-region','Display','off','MaxIterations',nMax);
dA_max = Err_min*10^3;                                                      
dA_min = Err_min/10^2;                                                      
dA_Start = Err_min*10;                                                      
du = Err_min/10;                                                            
dE_max = 0.1;                                                               
max_curv = sqrt(2);                                                         
ErrorPred_max = Err_min*10^2;                                               
nPred_max = 3;                                                              
iMax = Inf;    

clear

% load results
M_robot = load(['Manifold/M.mat']);
R_robot = load(['Manifold/R.mat']);
M1 = M_robot.M; 
R = R_robot.R;

% demo_Spatial
global eig_rng
eig_rng = 1:6;