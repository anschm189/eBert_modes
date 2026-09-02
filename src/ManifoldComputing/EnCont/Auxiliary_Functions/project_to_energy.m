function [x] = project_to_energy(unit_v,E_bar)
% Returns a vector x pointing from x_eq in the direction of unit_v such 
% that associated energy is E_bar
% It starts searching close to x_eq+a_guess*unit_v, which should ideally
% be close to energy E_bar.
% This function defines a retraction!

%% Assure that potential energy is non-decreasing, find initial guess:
global x_eq
step = .025;                                                                % Step for initial search
higher = 0;                                                                 % Boolean
up_bound = 0;                                                               % Rough Estimate
pe_old = -inf;
while higher == 0
    up_bound = up_bound + step;
    pe = V(x_eq + up_bound*unit_v,E_bar);
    if pe > 0
        higher = 1;
    end 
    if pe_old > pe                                                          % Condition for e.g. gravitational potential in pendulum
                                                                            % The potential energy is decreasing in this direction, stop
                                                                            %  searching!
        x = nan*x_eq;
        return
    end
    pe_old = pe;
end

%% Narrowing in:
if E_bar > 0
    alpha = fzero(@(a)(V(x_eq + a*unit_v,E_bar)),up_bound);                 % Small search window
    if isnan(alpha)
        alpha = fzero(@(a)(V(x_eq + a*unit_v,E_bar)),up_bound/10);           % Smaller search window
    end
else
    alpha = 0;
end


x = x_eq + alpha*unit_v;
