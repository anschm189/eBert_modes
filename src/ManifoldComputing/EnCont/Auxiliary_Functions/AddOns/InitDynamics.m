system_base = getenv('DynSystem');
if exist('numeric', 'var') == 0 % if variable does not exist
    numeric = false;
end
if exist([system_base, '/urdf'], 'dir') == 7 && ~numeric
    %% URDF file is given.
    warning('off'); rmpath(genpath([base, '/Auxiliary_Functions/AddOns/numeric'])); warning('on');
    urdf_struct = dir(fullfile([system_base, '/urdf'], '*.urdf'));
    if ~isempty(urdf_struct)
        urdf_file = [urdf_struct.folder, '/', urdf_struct.name];
        [robot,~] = urdf2robot(urdf_file);
        robot.g_vector = g_vector;
        nDoF = robot.n_q + 6 * robot.floating;
        robot.dof = robot.n_q + 6 * robot.floating;
        recreate_dynamics = true;
        recreate_gravity_only = false;
        recreate_potential = true;
        sha_hash.urdf = GetHash(urdf_file);
        sha_hash.gravity = GetHash([system_base, '/StartUp.m']);
        sha_hash.pot = GetHash([system_base, '/Potential.m']);
        if exist([system_base, '/.dyn'], 'dir') == 7 && exist([system_base, '/.dyn/sha_hash.mat'], 'file') == 2
            load([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
            if ~strcmp(sha_hash.gravity, oldsha_hash.gravity) && strcmp(sha_hash.urdf, oldsha_hash.urdf)
                recreate_gravity_only = true;
                recreate_dynamics = true;
            end
            if strcmp(sha_hash.urdf, oldsha_hash.urdf)
                if ~strcmp(sha_hash.gravity, oldsha_hash.gravity)
                    recreate_gravity_only = true;
                else
                    recreate_dynamics = false;
                end
            end
            if strcmp(sha_hash.pot, oldsha_hash.pot)
                recreate_potential = false;
            end
        elseif exist([system_base, '/.dyn'], 'dir') == 0
            mkdir([system_base, '/.dyn']);
            addpath([system_base, '/.dyn']);
        end
        if recreate_dynamics
            disp("Recomputing robot dynamics!");
            createEoM_urdf(robot, recreate_gravity_only);
            oldsha_hash = sha_hash;
            save([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
        end
        if recreate_potential
            disp("Recomputing potential fields and forces!");
            createPotential(robot);
            oldsha_hash = sha_hash;
            save([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
        end
    else
        error("No urdf file is given. Please either delete the urdf folder or input your robot urdf file.");
    end
elseif exist([system_base, '/urdf'], 'dir') == 7 && numeric
    %% URDF file is given and numeric evaluation of the eom is desired
    warning('off'); rmpath(genpath([system_base, '/Auxiliary_Functions/AddOns/symbolic'])); 
    addpath(genpath([base, '/Auxiliary_Functions/AddOns/numeric']));
    warning('on');
    urdf_struct = dir(fullfile([system_base, '/urdf'], '*.urdf'));
    if ~isempty(urdf_struct)
        urdf_file = [urdf_struct.folder, '/', urdf_struct.name];
        [robot,~] = urdf2robot(urdf_file);
        robot.g_vector = g_vector;
        nDoF = robot.n_q + 6 * robot.floating;
        robot.dof = robot.n_q + 6 * robot.floating;
        save([system_base, '/robot.mat'],'robot');
        recreate_potential = true;
        recreate_gravity = true;
        sha_hash.urdf = GetHash(urdf_file);
        sha_hash.gravity = GetHash([system_base, '/StartUp.m']);
        sha_hash.pot = GetHash([system_base, '/Potential.m']);
        if exist([system_base, '/.dyn'], 'dir') == 7 && exist([system_base, '/.dyn/sha_hash.mat'], 'file') == 2
            load([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
            if strcmp(sha_hash.pot, oldsha_hash.pot)
                recreate_potential = false;
            end
            if strcmp(sha_hash.gravity, oldsha_hash.gravity)
                recreate_gravity = false;
            end
        elseif exist([system_base, '/.dyn'], 'dir') == 0
            mkdir([system_base, '/.dyn']);
            addpath([system_base, '/.dyn']);
        end
        if recreate_gravity
            disp("Recomputing gravitational fields and forces!");
            createGravity(robot);
            oldsha_hash = sha_hash;
            save([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
        end
        if recreate_potential
            disp("Recomputing potential fields and forces!");
            createPotential(robot);
            oldsha_hash = sha_hash;
            save([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
        end
    else
        error("No urdf file is given. Please either delete the urdf folder or input your robot urdf file.");
    end
    
elseif exist([system_base, '/dynamics.m'], 'file') == 2
    %% EoM is given
    warning('off'); 
    rmpath(genpath([base, '/Auxiliary_Functions/AddOns/numeric'])); 
    addpath(genpath([base, '/Auxiliary_Functions/AddOns/symbolic']));
    warning('on');
    robot.dof = nDoF;
    recreate_dynamics = true;
    recreate_potential = true;
    sha_hash.dynamics = GetHash([system_base, '/dynamics.m']);
    sha_hash.pot = GetHash([system_base, '/Potential.m']);
    if exist([system_base, '/.dyn'], 'dir') == 7 && exist([system_base, '/.dyn/sha_hash.mat'], 'file') == 2
        load([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
        if strcmp(sha_hash.dynamics, oldsha_hash.dynamics)
            recreate_dynamics = false;
        end
        if strcmp(sha_hash.pot, oldsha_hash.pot)
            recreate_potential = false;
        end
    elseif exist([system_base, '/.dyn'], 'dir') == 0
            mkdir([system_base, '/.dyn']);
            addpath([system_base, '/.dyn']);
    end
    if recreate_dynamics
        disp("Recomputing robot dynamics!");
        createEoM(robot);
        oldsha_hash = sha_hash;
        save([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
    end
    if recreate_potential
        disp("Recomputing potential fields and forces!");
        createPotential(robot);
        oldsha_hash = sha_hash;
        save([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
    end
    disp('Init Completed!')
else
    warning('off'); rmpath(genpath([base, '/Auxiliary_Functions/AddOns/numeric'])); 
    addpath(genpath([base, '/Auxiliary_Functions/AddOns/symbolic']));
    warning('on');
    robot.dof = nDoF;
    recreate_potential = true;
    sha_hash.pot = GetHash([system_base, '/Potential.m']);
    if exist([system_base, '/.dyn'], 'dir') == 7 && exist([system_base, '/.dyn/sha_hash.mat'], 'file') == 2
        load([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
        if strcmp(sha_hash.pot, oldsha_hash.pot)
            recreate_potential = false;
        end
    elseif exist([system_base, '/.dyn'], 'dir') == 0
        mkdir([system_base, '/.dyn']);
        addpath([system_base, '/.dyn']);
    end
    if recreate_potential
        disp("Recomputing potential fields and forces!");
        createPotential(robot);
        oldsha_hash = sha_hash;
        save([system_base, '/.dyn/sha_hash'], 'oldsha_hash');
    end
end