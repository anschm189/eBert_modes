function [v, f, angles, energy] = createMesh(M, mode, save_mesh)
%% createMesh: creates a mesh structure from the Eigenmanifold
% This function connects states of the robot belonging to the Eigenmanifold
% of the generator with triangles. One node is always connected to each
% neighbouring node in the same evolution and to at least one node in the
% energy evolution below and above the current energy level.
% 
% [v, f, angles, energy] = createMesh(RBig, Y, generator, save_mesh)
%
% :return:
%   * v N x 2*nDoF matrix with each row being a state on the Eigenmanifold
%   * f k x 3 matrix with each row being one triangle in the mesh and each
%       row the corresponding node index in v
%   * angles b x 1 vector of angles in rad for the boundary nodes in v
%   * energy N x 1 vector of pseudo-energy for each node in v

disp("Triangulating state space manifold");
manifold = M{mode};
mesher = Mesher(manifold);
arc = 0;
boundary = mesher.boundary;
energy = mesher.energy;
for k=1:size(boundary,1)-1
    arc = arc + norm(boundary(k,:)-boundary(k+1,:));
end
arc = arc + norm(boundary(end,:)-boundary(1,:));
ratio = 2 * pi / arc;
arc = 0;
angles = zeros(size(boundary,1),1);
for k=2:size(boundary,1)
    arc = arc + norm(boundary(k-1,:)-boundary(k,:));
    angles(k) = arc * ratio;
end
% angles = weird_boundary(boundary);
fprintf(1,'Progress: %3d%%\n',0);
for i=1:size(mesher.manifold,1)-1
    %     disp(num2str(i) + " of " + num2str(size(mesher.manifold,1)-1));
    fprintf(1,'\b\b\b\b%3.0f%%',i/(size(mesher.manifold,1)-1)*100);
    finished = false;
    lower_mode = mesher.manifold{i,1};
    l_idx = 1;
    upper_mode = mesher.manifold{i+1,1};
    u_idx = 1;
    while ~finished
        [triangle, l_idx, u_idx, finished, mesher] = get_triangle(lower_mode, upper_mode, l_idx, u_idx, i, mesher);
%         plot_triangle(triangle, mesher);
        mesher.f = [mesher.f; triangle];
    end
    mesher.lower_helper = false;
    mesher.upper_helper = false;
end
fprintf('\n');
f = mesher.f;
v = mesher.v;
if save_mesh
    try
        if exist([getenv('DynSystem') '/Mesh'], 'dir') ~= 7
            mkdir([getenv('DynSystem') '/Mesh']);
            addpath([getenv('DynSystem') '/Mesh']);
        end
        save([getenv('DynSystem') '/Mesh/v'],'v')
        save([getenv('DynSystem') '/Mesh/f'],'f')
        save([getenv('DynSystem') '/Mesh/angles'],'angles')
    catch
        disp("Couldn't find directory to save the Files");
    end
end
%% TRIANGLES
function [f, l_idx, u_idx, finished, mesher] = get_triangle(lower, upper, l_idx, u_idx, i, mesher)
if i == 1
   mesher.lower_helper = true; 
end

if u_idx == size(upper,1)
    u_next = 1;
else
    u_next = u_idx + 1;
end
if l_idx == size(lower,1)
    l_next = 1;
else
    l_next = l_idx + 1;
end

if mesher.upper_helper == true
    dist1 = Inf;
else
    dist1 = norm(lower(l_idx,:) - upper(u_next,:));
end
if mesher.lower_helper == true
    dist2 = Inf;
else
    dist2 = norm(lower(l_next,:) - upper(u_idx,:));
end
f = [get_index(i, l_idx, mesher), 0, get_index(i+1, u_idx, mesher)];
if dist1 < dist2
    f(2) = get_index(i+1, u_next, mesher);
    if u_next == 1
        mesher.upper_helper = true;
    end
    u_idx = u_next;
else
    f(2) = get_index(i, l_next, mesher);
    if l_next == 1
        mesher.lower_helper = true;
    end
    l_idx = l_next;
end
if mesher.upper_helper == true && mesher.lower_helper == true
    finished = true;
else
    finished = false;
end
end

%% INDEX
function v = get_index(idx, eval, mesher)
v = mesher.start(idx)+eval-1;
end
end
