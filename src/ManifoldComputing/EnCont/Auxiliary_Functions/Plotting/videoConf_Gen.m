function [] = videoConf_Gen(Y,RBig,kG,Tags,ax_orig)
%VIDEOCONF_GEN video showing initial configuration over chosen generator
%   The video shows each of the modes on the generator in one frame, going
%   through the modes at 60fps

%% Initialization
fig = figure();
nDoF = size(Y,1);
nSearch = nDoF-1;                                                           
head = cell(nDoF,1);
h = cell(nDoF,1);


%% Initial Figure: Format
n3D = floor(nDoF/3) - (mod(nDoF-1,3)==0)*1;
n2D = 2 - mod(nDoF-1,3);
nGPlots = n3D + n2D;
ax = cell(nGPlots,1);

C0 = [0.1 0.15];
C1 = C0;
for i = 1:nGPlots
    if nGPlots <= 4 && (nDoF ~= 1)
        C1 = C0 + (i-1)*[0.9 0]/nGPlots;
        ax{i} = axes(fig,'Position',[C1 [0.8/nGPlots 0.8]]);
    elseif nGPlots > 4 && (nDoF ~= 1)                                       % Two rows once there are more than 4 plots
        if i <= 3
            C1 = C0 + (i-1)*[0.9/3 0] + [0 0.47];
            ax{i} = axes(fig,'Position',[C1 ([0.8/3 0.8/2])]);
        else
            C1 = C0 + (i-4)*[0.9/3 0];
            ax{i} = axes(fig,'Position',[C1 ([0.8/3 0.8/2])]);
        end
    else
        % Do nothing for nDoF = 1
    end
    view(ax{i},get(ax_orig{i},'View'));
end

%% Initial Figure: Plot
psi_e_inv = @(u_e,E) project_to_energy(phi2cart(u_e),E);                    % Transformation from energy shell centered on Equilibrium to configuration 
GeneratorToggle = findobj('Tag',Tags{7});
GeneratorSelection = findobj('Tag',Tags{8});
GeneratorHandles = plotGenerators_nDoF(ax,RBig,nGPlots,n3D,nSearch,nDoF,psi_e_inv);
if GeneratorToggle.Value
    IJK = size(GeneratorHandles);
    for i = 1:IJK(1)
        for j = 1:IJK(2)
            for k = 1:IJK(3)
                if j ~= GeneratorSelection.Value
                    delete(GeneratorHandles{i,j,k});
                end
            end
        end
    end
end
%% Making the animation
fps_des = 20;                                                               % desired framerate
IMax = size(Y{kG,1},1);
i = 1;
Labels = {};

while i <= IMax
    y = Y{kG,1}{i};                                                         % Select the next mode
    E = RBig{kG,1}(i,end);                                                  % Next energy level
    for j = 1:size(Labels,1)
    	delete(Labels{j});
    end
    Labels = cell(nGPlots,1);
    lower = 1;
    for k = 1:nGPlots
        hold(ax{k},'on')
        if (k <=n3D) && (nDoF > 1)
            Labels{k} = plot3(ax{k},Y{kG,1}{i}(:,lower),Y{kG,1}{i}(:,lower+1),Y{kG,1}{i}(:,lower+2),'LineWidth',1,'color','#77AC30');                                    % Updates with new trajectory
            lower = lower + 3;
        elseif (k > n3D) && (nDoF >1)
            Labels{k} = plot(ax{k},Y{kG,1}{i}(:,lower),Y{kG,1}{i}(:,lower+1),'LineWidth',1,'color','#77AC30');
            lower = lower + 2;
        end
        legend(Labels{k},strcat('E = ', strsplit(num2str(E))));
        hold(ax{k},'off')
    end
    hold off
%    addPotential(Toggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
%    title(fig,sprintf('Evolution on Generator %i for Energy: %.3f J', kG, E)); % Change Title
    
    drawnow
    Frames(i) = getframe(fig);
    for j = 1:nDoF
        delete(h{j});
        delete(head{j});
    end
    i =  i + 1;

end

%% Saving
video = VideoWriter(sprintf('vid_Conf_Gen_%i_E_%.0f.avi',kG,E));
video.FrameRate = fps_des;
open(video)
writeVideo(video,Frames);
close(video)
end



