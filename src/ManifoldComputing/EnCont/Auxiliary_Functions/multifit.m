function [y_fit] = multifit(R,t,n)
%MULTIFIT for R(:,j) = y(t(j)) predict y(t(end)+dt) = y_fit(dt) with n-th order polynomial
%   Error in the resulting y(t(end)+dt) is of order n+1. Uses polyfit. 
%   Output y_fit(dt) is a function of dt, with y(t(end)) = y_fit(0). 
%   n_max = size(R,2)

N = size(R,1);                                                              % Length of individual y
n_max = size(R,2)-1;                                                        % Maximum feasible number of iterations given measurements in R, which needs at least i+2*(n-1)-1
if n > n_max                                                                % Limiting Maximum Accuracy if required
    n = n_max; 
    fprintf('Accuracy in predict.m limited to %i for lack of measurements',n);
end

%% Construct coordinate-wise polynomial approximation 
t = t - t(end);                                                             % Make sure that t = 0 corresponds to last point
y_fit = @(dt)[];                                                            % Handle for full approximation

for i = 1:N
    [p,~,MU] = polyfit(t(end-n:end),R(i,(end-n):end),n);                    % Fit polynomial
    y_fit = @(dt) [y_fit(dt); polyval(p,dt,[],MU)];                         % Iterate over N coordinates 
end


end



