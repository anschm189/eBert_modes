%% Plot periods of generators in one plot
fig = figure();
figax = axes('Position',[0.15 0.15 0.75 0.75]);
Legend = cell(nDoF,1);
hold on                                                                     % Plot all modal evolutions for the current generator
pl = cell(1,nDoF);
for kG = 1:nDoF                                                             % Loop through generators
    T = RBig{kG,2};

    E = RBig{kG,3};
    Name = join(['Generator ',num2str(kG)]);
    Legend{kG,1} = Name;
    pl{kG} = plot(E,T,'linewidth',2,'DisplayName',Name);

end
xlabel('Pseudo-Energy in J','interpreter', 'latex', 'FontSize',16)
ylabel('Period in s','interpreter', 'latex', 'FontSize',16)
title('Cycle Periods vs. Energy','interpreter', 'latex', 'FontSize',16)
hl = legend(Legend);
set(hl,'Interpreter','latex','location','southeast')%,'orientation','horizontal')
set(figax,'TickLabelInterpreter', 'latex')
grid('on'), box('on') 

%% Place markers where energy starts decreasing / increasing:
for kG = 1:nDoF
    T = RBig{kG,2};
    E = RBig{kG,3};
    [~,IndPeaks]  = findpeaks(RBig{kG,1}(:,end));
    [~,IndTrophs] = findpeaks(-RBig{kG,1}(:,end));
    Ind = [IndPeaks;IndTrophs];
    for i = 1:length(Ind)
        I = Ind(i);
        if i <= length(IndPeaks)
            scatter(E(I),T(I),[],'b','v','filled','HandleVisibility','off');
        else
            scatter(E(I),T(I),[],'r','^','filled','HandleVisibility','off');
        end
    end
end
hold off
