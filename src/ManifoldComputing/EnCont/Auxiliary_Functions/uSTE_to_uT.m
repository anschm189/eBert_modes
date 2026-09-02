function [uT] = uSTE_to_uT(uSTE,nSearch)
%uSTE_to_uT Converts uSTE to uT, works for collections of column
%vectors
%   uSTE contains uS, period T and energy E, where uS contains the section
%   positions as demanded by MSPC. uT is equivalent to uSTE, but
%   on-energy-shell coordinates in uS are instead transformed back into 
%   configuration space coordinates by use of the energy level E

psi_e_inv = @(u_e,E) project_to_energy(phi2cart(u_e),E);                    % Transformation from energy shell centered on Equilibrium to configuration 
uT = zeros(size(uSTE,1)+1,size(uSTE,2));

for k = 1:size(uSTE,2)
    uS = uSTE(1:end-2,k);                                                   % Extract uS
    T = uSTE(end-1,k);                                                      % Extract T
    E = uSTE(end,k);                                                        % Extract E

    uT(:,k) = [psi_e_inv(uS(1:nSearch),E); uS(nSearch+1:end-nSearch);...    % Convert uS and E to u, return [u;T]
        psi_e_inv(uS(end+1-nSearch:end),E); T];                             
end

