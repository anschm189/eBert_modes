function [H] = makeH(uSTE_New,duSTE,nDoF,du,M)
%makeH Returns H, collection of vectors orthogonal to the generator curves
%   duSTE is expected to be tangent to the generator curve. 
%   Degrees of freedom nDoF, and numerical differencing step du are as  
%   defined in MS.m.
%   The metric M of the configuration space should be an nDoF*nDoF matrix. 

% Brief explanation of derivation:
%   With dX a small change at X on a space with metric M(x),dY is 
%   orthogonal to dX w.r.t. M iff M(x)(dX,dY) = 0, i.e. dY'*M(x)*dX = 0. So
%   dX merely needs to be transformed through the metric, and then the
%   orthogonal space can be found as below. Below, dX = dU =
%   pinv(JacEn)*duSE, such that the orthogonal vector is also only searched
%   in the span of pinv(JacEn). Last, the collection of dY is translated 
%   back to the form duSE, giving H = JacEn*dY. 

%% Metric choice on configuration space:
M = eye(nDoF);
M1 = M;                                                                     % Metric evaluated at first on-shell point
M2 = M;                                                                     % Metric evaluated at second on-shell point
nSearch = nDoF-1;
n_offShell = length(duSTE) - 2*nSearch - 2;                                 % n_offShell is a multiple of 2*nDoF
BigM = blkdiag(M1,M2);

%% Transformations to and from energy shell
global x_eq;
psi_e = @(u_red) cart2phi((u_red-x_eq)/norm(u_red-x_eq));                   % Transformation from configuration to energy shell centered on Equilibrium
psi_e_inv = @(u_e,E) project_to_energy(phi2cart(u_e),E);                    % Transformation from energy shell centered on Equilibrium to configuration 

%% Jacobian to transform tangent vectors to configuration space
JacEn = numJ(@(x)[psi_e(x(1:end/2));psi_e(x(end/2+1:end));V(x(1:end/2),0)],...
    [psi_e_inv(uSTE_New(1:nSearch),uSTE_New(end)); ...
    psi_e_inv(uSTE_New(end-nSearch-1:end-2),uSTE_New(end))],du);            % Jacobian of transformation to energy coordinates for transformed coordinates

duSE = [duSTE(1:nSearch);duSTE(end-nSearch-1:end-2);duSTE(end)];            % Energy shell coordinates for first section

JacInv = pinv(JacEn);                                                       % Pseudo-inverse: Desired, see explanation above
dU = BigM*JacInv*duSE;                                                      % Transform on-energy-shell coordinates to configuration space

%% Determine H
H = JacEn*reduce_base(dU/norm(dU),BigM*JacInv);                             % Main calculation: Orthogonal basis w.r.t. metric, and in plane spanned by BigM*JacInv

H11 = H(1:nSearch,1:nSearch);                                               % Free search over remaining sections: They could be included if they were also in energy coordinates
H12 = H(1:nSearch,nSearch+1:end);
H21 = H(nSearch+1:end,1:nSearch);
H22 = H(nSearch+1:end,nSearch+1:end);
H = blkdiag(H11,eye(n_offShell),H22);                                       % Assembly
H(1:nSearch,end+1-nSearch:end) = H12;
H(end-nSearch:end,1:nSearch) = H21;


H = [H(1:end-1,:);zeros(size(H(end,:))); H(end,:)];
H = [zeros(size(H,1),1),H];                                                 
H(end-1,1) = 1;
H = orth(H);                                                                % Final step to make H an orthogonal basis. Not absolutely necessary, but possibly numerically advantageous.
    
end

