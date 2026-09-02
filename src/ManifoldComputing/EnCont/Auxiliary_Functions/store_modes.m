function [Y] = store_modes(RBig,nDoF,nSearch,psi_inv,opts)
%STORE_MODES Calculates full trajectories on generator and returns modal coordinates
%   The output (nDoF by 3) cell Y contains information about nDoF 
%   generators, where Y{i,1}{k} contains the k-th trajectory on generator 
%   i, associated with energy level RBig{i,2}(k). Y{i,2}{k} contains the 
%   k-th trajectory on the i-th generator in modal coordinates. Y{i,3}{k}
%   contains the time along the i-th generator. Y{i,4}{k} optionally 
%   contains the cycle multipliers.
%   psi_inv should lead from the coordinates in RBig to a valid initial condition
%   in statespace (i.e. either psi_inv(u) or psi_inv(psi_e_inv(u,E))

Y = cell(nDoF,3);                                                           % Container for solutions after processing
du = 10^2*opts.AbsTol;

for i = 1:nDoF
    Y{i,1} = cell(size(RBig{i,1},1),1);                                     % Trajectories on ith Generator
    Y{i,2} = cell(size(RBig{i,1},1),1);                                     % Trajectories in Modal Coordinates on ith Generator: Arc-length and changerate of arc-length
    Y{i,3} = cell(size(RBig{i,1},1),1);                                     % Time along trajectories on ith Generator
    Y{i,4} = cell(size(RBig{i,1},1),1);                                     % Contains cycle multipliers of cycles on ith Generator
    
    for k = 1:size(RBig{i,1},1)
        %% 7.1 Constructing all periodic trajectories from generators
        u_red = RBig{i,1}(k,1:nSearch);                                     % Starting point of i-th generator
        T = RBig{i,2}(k);                                                   % Period of associated orbit
        if nSearch == nDoF                                                  % First half of orbit, might need energy E for psi_inv
            [y,t1] = shoot(psi_inv(u_red.'),T/2,'full',opts);               % 1st half of orbit
            t1 = t1/2;
        else
            E = RBig{i,1}(k,end);                                           % Energy of starting point
            [y,t1] = shoot(psi_inv(u_red.',E), T/2,'full',opts);            % 1st half of orbit
            t1 = t1/2; 
        end
        Y1 = y;
        [y,t2] = shoot(Y1(end,:)',T/2,'full',opts);                          % 2nd half of orbit
        t2 = 1/2+t2/2;
        Y2 = y;
        t = [t1;t2(2:end)];                                                        
        Y{i,3}{k} = t*RBig{i,2}(k);                                         % Scale t by actual period
        dt = gradient(t')';                                                 % Simulation has variable time step
        Ly1 = size(Y1,1);                                                   % Length of first half of trajectories
        Y{i,1}{k} = [Y1;Y2(2:end,:)];                                       % Full trajectory
        dY = Y{i,1}{k}(:,nDoF+1:2*nDoF);                                    % Change rates of configuration
        yM = cumsum(vecnorm(dY(1:Ly1,:),2,2).*dt(1:Ly1))-norm(Y{i,1}{k}(1,1:3));% Modal position on first half
        yEnd = yM(end);
        yM = [yM; yEnd - cumsum(vecnorm(dY(Ly1+1:end,:),2,2).*dt(Ly1+1:end))];% Modal position on full trajectory
        dyM = [vecnorm(dY(1:Ly1,:),2,2);-vecnorm(dY(Ly1+1:end,:),2,2)];                                              % Modal velocity
        EPot = zeros(length(t),1);                                          % Potential energy along mode
        for l = 1:length(t)
            EPot(l) = V(Y{i,1}{k}(l,1:nDoF)',0);
        end 
        Y{i,2}{k} = [yM,dyM,EPot]; 
        
        %% 7.2 Monitoring Cycle Stability                          
    %     %    If this becomes of interest, it's much more efficient to do
    %     %    this during the continuation in MS.m, especially because the
    %     %    eigenvalues of this matrix also allow monitoring common 
    %     %    bifurcations during continuation. But that was outside the 
    %     %    scope of this internship.
    %    J = numJ(@(u)shoot(u,T,'end',opts),psi_inv(u_red.',E),du);
    %    E = eig(J);
    %    Y{i,4}{k} = abs(E);
    end
end

end
