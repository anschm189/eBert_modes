function Handles = plotGenerators_nDoF(ax,RBig,nGPlots,n3D,nSearch,nDoF,psi_e_inv)
%PLOTGENERATORS_NDOF Only used by nDoF_GUI, plots generators into n plots
%   Largely an adaptation of plotGenerators.m, which does this for nDoF = 2
%   and nDoF = 3

%% Initialization
    numGen = (size(RBig{1,1},2)-1)/nSearch;                                 % Number of generator halves stored in RBig
    Legend = cell(nDoF*numGen,1);                                               
    Handles = cell(nGPlots,nDoF,numGen);
    lower = 1;

%% Looping through plots and drawing all generators
    for k = 1:nGPlots                                                       % Go through all figures in pGens
        hold(ax{k},'on')
        cla(ax{k});                                                         % Clear Plots                                  
        colors = hsv(numGen*nDoF);
        for j = 1:numGen                                                    % Plot projections of generators
            for kG = 1:nDoF                                                 % (Both halfs for all nDoF generators)
                %% Extracting generators
                R = zeros(size(RBig{kG,1},1),nDoF);
                for i = 1:size(RBig{kG,1},1)
                    if nSearch == nDoF                                      % Translate from energy coordinates to configuration space if required
                        R(i,:) = RBig{kG,1}(i,(j-1)*nSearch+1:...
                                (j-1)*nSearch+nSearch);
                    else
                        R(i,:) = psi_e_inv(RBig{kG,1}(i,(j-1)*nSearch+1:...
                                    (j-1)*nSearch+nSearch)',RBig{kG,1}(i,end))';
                    end
                end
                %% Plotting Generators
                if k <= n3D && (nDoF > 1)                                   % Choose number of coordinates per plot
                    Handles{k,kG,j} = plot3(ax{k},R(:,lower),R(:,lower+1),R(:,lower+2),'LineWidth',2,'Color',colors((j-1)*nDoF+kG,:));
                    view(ax{k},[1 1 1]);
                elseif k >= n3D && (nDoF > 1)
                    Handles{k,kG,j} = plot(ax{k},R(:,lower),R(:,lower+1),'LineWidth',2,'Color',colors((j-1)*nDoF+kG,:));
                    view(ax{k},[0 0 1]);
                else 
                    %Do nothing for nDoF = 1;
                end
                Legend{(j-1)*nDoF+kG} = sprintf('Generator %d.%d', kG,j);
            end
        end
        %% Labeling axes
        xlabel(ax{k},sprintf('$\\theta_%i$ in rad',lower),'interpreter', 'latex', 'FontSize',16);
        ylabel(ax{k},sprintf('$\\theta_%i$ in rad',lower+1),'interpreter', 'latex', 'FontSize',16);
        if k <= n3D
            zlabel(ax{k},sprintf('$\\theta_%i$ in rad',lower+2),'interpreter', 'latex', 'FontSize',16);
        end
        if k == 1
            hl = legend(ax{k},Legend);
            set(hl,'Interpreter','latex','location','southeast')%,'orientation','horizontal')
        end
        set(ax{k}, 'TickLabelInterpreter', 'latex')
        grid(ax{k},'on'), box(ax{k},'on')
        lower = lower + (k <= n3D) + 2;                                     % Update lower index of coordinates
    end
    hold off
end


