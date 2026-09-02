%% Only plots generators after RBig was loaded using Load.m. Optionally also allows to plot modes.

fig = figure();


n3D = floor(nDoF/3) - (mod(nDoF-1,3)==0)*1;
n2D = 2 - mod(nDoF-1,3);
nGPlots = n3D + n2D;
Scale = 2 + floor((nGPlots-1)/4);
sRem = 1/Scale;
sGens = 1-sRem;
axGen = cell(nGPlots+1,1);

C0 = [0.1 0.15];
C1 = C0;
for i = 1:nGPlots
    if nGPlots <= 4 && (nDoF ~= 1)
        C1 = C0 + (i-1)*[0.9 0]/nGPlots;
        axGen{i} = axes(fig,'Position',[C1 [0.8/nGPlots 0.8]]);
    elseif nGPlots > 4 && (nDoF ~= 1)                                       % Two rows once there are more than 4 plots
        if i <= 3
            C1 = C0 + (i-1)*[0.9/3 0] + [0 0.47];
            axGen{i} = axes(fig,'Position',[C1 ([0.8/3 0.8/2])]);
        else
            C1 = C0 + (i-4)*[0.9/3 0];
            axGen{i} = axes(fig,'Position',[C1 ([0.8/3 0.8/2])]);
        end
    else
        % Do nothing for nDoF = 1
    end
end


plotGenerators_nDoF(axGen,RBig,nGPlots,n3D,nSearch,nDoF,psi_e_inv);

%% Add a particular mode if desired
%% 
% kG = 5;                                                       % Generator
% I = 62;                                                       % Mode Index
% if exist('ModeHandles')                                       
%     addMode(I,1,axGen,Y,RBig,kG,nGPlots,nDoF,n3D,ModeHandles); 
% else 
%     ModeHandles = {};
%     addMode(I,1,axGen,Y,RBig,kG,nGPlots,nDoF,n3D,ModeHandles);
% end

%% Internal functions used here


function [ModeHandles] = addMode(I,Toggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,ModeHandles)
E = RBig{kG,1}(I,end);
lower = 1;
for i = 1:size(ModeHandles,1)
    delete(ModeHandles{i});
end
ModeHandles = cell(nGPlots,1);
   
for k = 1:nGPlots
    hold(ax{k},'on')
    if (k <=n3D) && (nDoF > 1)
        ModeHandles{k} = plot3(ax{k},Y{kG}{I}(:,lower),Y{kG}{I}(:,lower+1),...
            Y{kG}{I}(:,lower+2),'LineWidth',1,'color','#77AC30',...
            'DisplayName',sprintf('E = %2.f', E));                                    % Updates with new trajectory
        lower = lower + 3;
    elseif (k > n3D) && (nDoF >1)
        ModeHandles{k} = plot(ax{k},Y{kG}{I}(:,lower),Y{kG}{I}(:,lower+1),...
            'LineWidth',1,'color','#77AC30',...
            'DisplayName',sprintf('E = %2.f', E));
        lower = lower + 2;
    end
    %legend(ModeHandles{k},sprintf('E = %2.f', E));
end
hold off
Slider.UserData.Handles = ModeHandles;
end
