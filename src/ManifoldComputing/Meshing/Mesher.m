classdef Mesher
    %% Properties
    properties
        manifold
        start
        v
        f
        upper_helper
        lower_helper
        energy
        boundary
    end
    %% Methods
    methods
        %% Init
        function obj = Mesher(M)
            manifold_old = recreateManifold(M);
            manifold_old{1,1} = manifold_old{1,1}(1,:);
            obj.manifold = manifold_old;
            obj.v = M.manifold;
            obj.start = 1;
            obj.energy = M.pseudo_energy;
            for i=1:size(obj.manifold,1)
                obj.start = [obj.start;size(obj.manifold{i,1},1)+obj.start(end)];
            end
            obj.f = zeros(0,3);
            obj.upper_helper = false;
            obj.lower_helper = false;
            obj.boundary = manifold_old{end,1};
        end
    end
end

function manifold = recreateManifold(M)
v = M.manifold;
energy = M.pseudo_energy;
index = 1;
lower = 1;
for k=1:numel(energy)
    if energy(k) > energy(lower)
        manifold{index,1} = v(lower:k-1,:);
        lower = k;
        index = index + 1;
    end
end
manifold{index,1} = v(lower:k,:);
end