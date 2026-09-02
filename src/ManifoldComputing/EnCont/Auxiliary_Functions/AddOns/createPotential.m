function createPotential(robot)
system_base = getenv('DynSystem');
dyn_folder = [system_base, '/matFun'];
if exist(dyn_folder, 'dir') ~= 7
    mkdir(dyn_folder);
    addpath(dyn_folder);
end

if (robot.dof <= 3)
    q = sym('q_%d',[robot.dof 1],'real');
    pot = Potential(q);
    matlabFunction(pot, 'file', [dyn_folder, '/V_Spring'], 'vars', {q});
    
    spring = gradient(pot, q);
    
    % % spring = sym(zeros(robot.dof,1));
    % % parfor ii=1:robot.dof
    % %     spring(ii) = jacobian(pot, q(ii));
    % % end
    %
    % % addpath(genpath('/home/calz_da/devel/CORA_2020'))
    % % spring_pruned = simplify_remove_epsilon_terms(vpa(spring,5).', 1e-10, q, false).';
    % % rmpath(genpath('/home/calz_da/devel/CORA_2020'))
    
    matlabFunction(spring, 'file', [dyn_folder, '/spring'], 'vars', {q}, 'Optimize', false);
end

end