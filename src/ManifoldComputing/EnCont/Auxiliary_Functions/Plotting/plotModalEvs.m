function [fig] = plotModalEvs(Y,RBig,nDoF,p)
%PLOTMODALEVS Plots the modes in modal coordinates + potential energy
%   Y results from store_modes.m. RBig contains generators and 
%   results from continuation. nDoF are the degrees of freedom. 
%   Only every p-th mode on each generator is plotted   
%   The output is a cell of nDoF figure and axis handles.

fig = cell(nDoF,2);                                                         % Empty cell for figure handles
for kG = 1:nDoF                                                             % Loop through generators
    fig{kG,1} = figure();
    figax = axes('Parent',fig{kG,1},'position',[0.13 0.3 0.77 0.6]);
    hold on                                                                 % Plot all modal evolutions for the current generator
    for k = 1:floor(size(RBig{kG,1},1)/p)
        yM = Y{kG,2}{k*p}(:,1);
        dyM = Y{kG,2}{k*p}(:,2);
        EPot = Y{kG,2}{k*p}(:,3);
        plot3(yM,dyM,EPot,'linewidth',2);
    end
    hold off
    axis('manual')
    xlabel('Modal Position in rad','interpreter', 'latex', 'FontSize',16);
    ylabel('Modal Velocity in rad/s','interpreter', 'latex', 'FontSize',16);
    zlabel('Potential Energy in J','interpreter', 'latex', 'FontSize',16);
    topic = join(['Modal Evolutions on Generator ',num2str(kG)]);
    title(topic,'interpreter', 'latex', 'FontSize',16);
    set(figax,'TickLabelInterpreter', 'latex');
end

end
