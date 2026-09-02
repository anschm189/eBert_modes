function [uSTE] = uT_to_uSTE(uT,nSearch)
%uT_to_uSTE Converts uTE to uSTE
%   uSTE contains uS, period T and energy E, where uS contains the section
%   positions as demanded by MSPC. uT is equivalent to uSTE, but
%   on-energy-shell coordinates in uS are instead transformed back into 
%   configuration space coordinates by use of the energy level E 

global x_eq
psi_e = @(u_red) cart2phi((u_red-x_eq)/norm(u_red-x_eq));                   % Transformation from configuration to energy shell centered on Equilibrium

u = uT(1:end-1);                                                            % Extract u
T = uT(end);                                                                % Extract T
E = V(u(1:nSearch+1),0);                                                    % Determine energy

uSTE = [psi_e(u(1:(nSearch+1))); u(nSearch+2:end-nSearch-1);...
    psi_e(u(end-nSearch:end)); T; E];                                       % Transform 
end

                                    