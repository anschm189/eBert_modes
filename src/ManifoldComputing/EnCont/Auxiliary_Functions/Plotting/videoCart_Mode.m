function [] = videoCart_Mode(YCart,RBig,kG,Tags)
%VIDEOCART_MODE Makes a video of the pendulum motion for the selected mode
%   The video is slowed down to 20% by default, and has a framerate of
%   120fps

fig = figure();
ax = axes(fig,'Position',[0.1 0.1 0.8 0.8]);
% xlim([-1.25, 1.25]);
% ylim([-0.4, 2.1]);
nDoF = size(YCart,1);
% curve = cell(nDoF,1);
head = cell(nDoF,1);                                                        % Handles for masses (scatter points)
links = cell(nDoF,1);                                                       % Handles for links between masses

h = findobj('Tag',Tags{1});                                                 
I = h.UserData.val;                                                         % Index from slider value


%% Initial Figure
y = YCart{kG,1}{I};                                                         % Select the current mode
E = RBig{kG,1}(I,end);                                                      % Current energy level
% Legend = cell(nDoF,1); 

hold(ax,'on');
for j = 1:nDoF
     plot(y(:,(j-1)*2+1),y(:,(j-1)*2+2),'LineWidth',2);
     Name = sprintf('Mass %i',j);
     Legend{j,1} = Name;
     % curve{j} = animatedline('LineWidth',1);
end
axis('equal')
xlabel('x in m','interpreter', 'latex', 'FontSize',18)
ylabel('y in m','interpreter', 'latex', 'FontSize',18)
title(sprintf('Evolution on Generator %i for Energy: %.2f J', kG, E));
set(ax, 'TickLabelInterpreter', 'latex')
grid(ax,'on'), box(ax,'on')

%% Making the animation
slowing = 0.2;                                                              % runs at 20% the usual speed
dt = gradient(YCart{kG,2}{I}');
fps_des = 120;                                                              % desired framerate
T = RBig{kG,2}(I);                                                          % Period of current mode
if (T >= 1)                                                                 % Makes sure video duration is at least 1 second
    dt_lim = 1/fps_des;                                                     % limit at which new frame is made
else
    dt_lim = T/fps_des;
end
dt_sum = 0;
k = 1;                                                                      % Used as frame counter
i = 1;

while i <= size(y,1)
    y_prev = [0,0];
    for j = 1:nDoF
        y_new = [y(i,(j-1)*2+1),y(i,(j-1)*2+2)];
        % addpoints(curve{j},y(i,(j-1)*2+1),y(i,(j-1)*2+2));                % Updates with new trajectory
        head{j} = scatter(y_new(1),y_new(2),'filled', ...
            'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
        links{j} = plot([y_prev(1),y_new(1)],[y_prev(2),y_new(2)],'LineWidth',1,'color','b');        
        y_prev = y_new;
    end
    drawnow
    Frames(k) = getframe(fig);
    k = k+1;
    for j = 1:nDoF
        delete([head{j},links{j}]);
    end
    while dt_sum < dt_lim                                                   % Skip points until it's time for the next frame, appropriate to time scaling
        dt_sum = dt_sum + dt((i-1)*(i<end)+1);
        i = i + 1;
        if i == size(y,1)                                                   % Stop at last frame
            break
        end
    end
    dt_sum = 0;                                                             % Reset counter
end
hold(ax,'off')

%% Saving
video = VideoWriter(sprintf('vid_Cart_Mode_Gen_%i_E_%.0f.avi',kG,E));
video.FrameRate = floor(slowing/dt_lim);
open(video)
writeVideo(video,Frames);
close(video)

end

