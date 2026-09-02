function [ Discrepancy ] = MSPC(uS, T, nS_2, dim_u, dim_M, dim_uS, opts, E)
%MSPC Returns result of periodicity condition for multiple shooting
%   Uses and expects energy coordinates.
%
%   f(u,T) is the function used for the dynamic system u' = f(u,T). 
%   uS contains the variables of all sections. T is the current time
%   scaling.
% 
%   nS_2 >= 1 adapts the number of sections, which is twice nS_2. 
%   For nS_2 = 1, each section corresponds to one end of a given generator.
%   Afterwards, sections are spaced at regular time intervals over the
%   trajectory.
%
%   dim_uS contains the lengths of the variables describing the sections in uS. 
%   opts are the options for the integrator, here ode45. 
%   Input uS should be a column vector of length sum(dim)+dim(1), the output is a 
%   column vector of length 2*sum(dim);.
%   E is the current energy level.

%% Structure:
% uS has the following structure: [1st Section on Energy Shell
% (Configuration Vector); Full State Vectors for Off-Energy Shell Sections;
% 2nd Section on Energy Shell (Configuration Vector)];

% The output discrepancy has the following structure:
% Discrepancy = [Discrepancy; Difference between i-th and (i+1)-th section on path] 
% for i running from the 1st section via the 2nd section and back to the
% first section such that (i+1)-th section is 1st section, in the end.

%% Parameters:
% fprintf('+');

if nS_2 < 1                                                                 % Making sure nS is a proper count of all sections, i.e. even
    nS = 2;
else
    nS = 2*nS_2;
end

%% Transformations:
psi = @(u) [u(1:dim_M)];                                                    % From State Space to Configuration Space
psi_inv = @(u_red,E) [u_red; zeros(dim_u-dim_M,1)];                         % From Configuration Space to State Space with velocity = 0
if dim_uS(1) < dim_M
    psi = @(u) cart2phi(psi(u)-xeq);                                        % Transformation from State Space energy shell centered on Equilibrium
    psi_inv = @(u_e,E) psi_inv(project_to_energy(phi2cart(u_e),E));         % Transformation from energy shell centered on Equilibrium to State Space
end
pi = @(u) [u(1:dim_M); -u(dim_M+1:dim_u)];                                  % From one section to its counter part
Ind = @(i) i*(i<=nS/2+1)+(nS+2-i)*(i>nS/2+1);                               % Returns index of section for i up to nS_2, returns corresponding index after 


%% Setting dim_D, the corresponding lengths of the discrepancy              % Appended by one more dim_u, to simplify looping back to the start below
if nS == 2
    dim_D = [dim_u;dim_u;dim_u];                                            % Full State Space Difference is used
else
    dim_D = [dim_u; dim_uS(2:end-1); dim_u; dim_uS(2:end-1); dim_u];        % Read: 1st Section on Energy Shell, Sections between Energy Shells, 2nd Section on Energy Shell, Sections between Energy Shell on reverse path, 1st Section on Energy Shell
end
Discrepancy = zeros(dim_u*(nS),1);                                            

%% Periodicity Condition


for i = 1:nS
    %% Pick current starting section from uS:
    j = Ind(i);                                                             % Translate to proper index
    upper_uS = sum(dim_uS(1:j));                                            % End of current section in full variable vector uS
    upper_D = sum(dim_D(1:i));                                              % End of current evaluation in Discrepancy vector
    lower_uS = upper_uS - dim_uS(j) +1;                                     % Start of current section in uS
    lower_D = upper_D - dim_D(i) + 1;                                       % Start of current section in Discrepancy
    if dim_uS(j) ~= dim_u                                                   % Apply transformations if current section length implies one is needed
        u0 = psi_inv(uS(lower_uS:upper_uS),E);
    else 
        u0 = uS(lower_uS:upper_uS);
    end
    
    %% Pick goal point from uS
    j1 = Ind(i+1);                                                          % Repeat procedure for section that is "shot at"
    upper_uS1 = sum(dim_uS(1:j1));
    lower_uS1 = upper_uS1 - dim_uS(j1) +1;
    if dim_uS(j1) ~= dim_u
        u1 = psi_inv(uS(lower_uS1:upper_uS1),E);
    else 
        u1 = uS(lower_uS1:upper_uS1);
    end
    
    %% Adapt sections on 2nd half of mode:
    if i >=nS/2+1                                                           % I.e. transform velocity component for sections on backwards path
        u0 = pi(u0);                                                        % Happens once for 2nd section on potential energy shell, where it has no effect - that simplified code
        u1 = pi(u1);
    end
    
    %% Evaluate Discrepancy
    D = shoot(u0,T/nS,'end',opts)-u1;                                       % Scale time, rather than adapting evaluation interval - does not matter for ode45
    Discrepancy(lower_D:upper_D) = D;                                   
end
 

end

