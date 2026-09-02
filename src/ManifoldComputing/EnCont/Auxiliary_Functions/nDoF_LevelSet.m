function [H] = nDoF_LevelSet(x,i,j)
%nDoF_LevelSet Returns intersection of the hyperplane orthogonal to
%grad(V(x)) with subspace x(i:j) at x
% This function should run after V(x,E) for a specific system is added to
% the path

dx = 10^-5;                                                                 % Numerical differencing step
nDoF = length(x);
gradV = numJ(@(u)V(u,0),x,dx)';                                             % Gradient
gradV = gradV/norm(gradV);                                                  % normalized Gradient
gradV_co = [zeros(i-1,1);gradV(i:j);zeros(nDoF-j,1)];                       % Gradient with zeros for uninteresting dimensions
gradV_co = gradV_co/norm(gradV_co);                                         % Matrix with vectors orthogonal to intersection

H = reduce_base([gradV,gradV_co]);                                          % Hyperplane orthogonal to gradV and gradV_co
                                                      
H = H(i:j,:);                                                              
[H,S] = svd(H);                                                            
S = sum(diag(S)>dx);                                                        % Use dx as threshold for singular directions
H = H(:,1:S);                                                               % Intersection of hyperplane with chosen subset

end
