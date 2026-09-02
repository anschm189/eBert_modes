function [] = videoCart_Gen(YCart,RBig,kG)
%VIDEOCART_GEN video showing initial configuration over chosen generator
%   The video shows each of the modes on the generator in one frame, going
%   through the modes at 30fps

fig = figure();
ax = axes(fig,'Position',[0.1 0.1 0.8 0.8]);
nDoF = size(YCart,1);
% curve = cell(nDoF,1);
head = cell(nDoF,1);                                                        % Handles for masses (scatter points)
evs = cell(nDoF,1);                                                         % Handles for evolutions of masses
links = cell(nDoF,1);                                                       % Handles for links between masses
colors = hsv(nDoF);

%% Initial Figure
IMax = size(YCart{kG,1},1);
y = YCart{kG,1}{IMax};                                                      % Select the current mode
E = RBig{kG,1}(IMax,end);                                                   % Current energy level
% Legend = cell(nDoF,1); 

% gen_Cart = zeros(2*nDoF,IMax);                                              % Stores generators in cartesian coordinates, link coordinates for given index in each column
% for i = 1:IMax
%     gen_Cart(:,i) = YCart{kG,1}{i}(1,:)';                                   
% end

hold(ax,'on');
for j = 1:nDoF
     scatter(0,0,'filled', ...
            'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');                % Origin for fixed world position
%      plot(gen_Cart((j-1)*2+1,:),gen_Cart((j-1)*2+2,:));                     % Plot generator in Cartesian coordinates
     evs{j} = plot(y(:,(j-1)*2+1),y(:,(j-1)*2+2),'LineWidth',2,'Color',colors(j,:));            % plot mode
     Name = sprintf('Mass %i',j);
     Legend{j,1} = Name;
     % curve{j} = animatedline('LineWidth',1);
end
axis('equal'); axis('manual');
xlabel('x in m','interpreter', 'latex', 'FontSize',18)
ylabel('y in m','interpreter', 'latex', 'FontSize',18)
title(sprintf('Evolution on Generator %i for Energy: %.3f J', kG, E));
set(ax, 'TickLabelInterpreter', 'latex')
grid(ax,'on'), box(ax,'on')

for j = 1:nDoF
    delete(evs{j});
end

%% Making the animation
fps_des = 20;                                                               % desired framerate
i = 1;

while i <= IMax
    y = YCart{kG,1}{i};                                                     % Select the next mode
    E = RBig{kG,1}(i,end);                                                  % Next energy level
    y_prev = [0,0];                                                         % Position of mass of previous link
    for j = 1:nDoF
        evs{j} = plot(y(:,(j-1)*2+1),y(:,(j-1)*2+2),'LineWidth',2,'Color',colors(j,:));
        % addpoints(curve{j},y(i,(j-1)*2+1),y(i,(j-1)*2+2));                % Updates with new trajectory
        y_new = [y(1,(j-1)*2+1),y(1,(j-1)*2+2)];
        head{j} = scatter(y_new(1),y_new(2),'filled', ...
            'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
        links{j} = plot([y_prev(1),y_new(1)],[y_prev(2),y_new(2)],'LineWidth',1,'color','b');
        y_prev = y_new;
    end
    title(ax,sprintf('Evolution on Generator %i for Energy: %.3f J', kG, E)); % Change Title
    
    drawnow
    Frames(i) = getframe(fig);
    for j = 1:nDoF
        d = [evs{j},head{j},links{j}];
        delete(d);
    end
    i =  i + 1;
end
hold(ax,'off')

%% Saving
video = VideoWriter(sprintf('vid_Cart_Gen_%i_E_%.0f.avi',kG,E));
video.FrameRate = fps_des;
open(video)
writeVideo(video,Frames);
close(video)
end

