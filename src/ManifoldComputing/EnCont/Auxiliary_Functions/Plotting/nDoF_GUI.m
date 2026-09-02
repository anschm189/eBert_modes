function nDoF_GUI(RBig,Y,nDoF,nSearch,psi_e_inv)
%% Creates a GUI to inspect results of continuation
% Upper right corner shows plot of modes in Cartesian coordinates at
% current energy level.
% Bottom plots contain generators and a mode on the currently selected
% generator at the currently energy level.
% Upper left corner allows choice between generators, gives a slider to
% pick the energy of the mode, and gives a button to save a video of the
% current mode, displayed in joint space.

% For the generator plots, nDoF from 2 to 18 can be displayed:
% With nDoF = n, this would result in
%  If    mod(n-1,3) == 1, then floor(n/3) 3D plots and one 2D plot
%  If    mod(n-1,3) == 2:, then n/3 3D plots
%  If    mod(n-1,3) == 0, then floor(n/3)-1 3D plots and two 2D plots
% i.e. the amount of 3D plots is maximized and 1D plots are forbidden. E.g.
% for 2: one in 2D
% for 3: one 3D
% for 4: two 2D
% for 5: one 3D, one 2D
% for 6: two 3D
% for 7: one 3D, two 2D
% etc.

%% Converting modes to cartesian coordinates
global FKIN_EXISTS;
FKIN_EXISTS = exist('fKin.m','file');
if ~FKIN_EXISTS
    fprintf("No file for forward kinematics, plots of the system are left out");
    YCart = 0;
else
    YCart = ConfToCart(Y,nDoF);
end

%% 1. Determining the GUI Format:
n3D = floor(nDoF/3) - (mod(nDoF-1,3)==0)*1;                                 % number of 3D plots
n2D = 2 - mod(nDoF-1,3);                                                    % number of 2D plots
nGPlots = n3D + n2D;                                                        % total number of plots
Scale = 2 + floor((nGPlots-1)/4);                                           % Formatting: more space for Generators if more more than 4 plots
sRem = 1/Scale;                                                             % sRem + sGens = 1 required. sRem gives space for panels oter than pGens
sGens = 1-sRem;                                                             % sGens gives space for pGens

%% 2. Panels for Figures/ Control:
figure()
pUser = uipanel('Title', 'Input','FontSize',12,...                          % Panel with user buttons
                'BackgroundColor','white',...
                'Position',[.01 .01+0.99*sGens 0.44 1*sRem]);
pCart = uipanel('Title', 'Cartesian Modes','FontSize',12,...                % Panel with plot of actual manipulator
                'BackgroundColor','white',...
                'Position',[.45 .01+0.99*sGens 0.54 1*sRem]);
pGens = uipanel('Title','Generators','FontSize',12,...                      % Panel with generators / modes in configuration space
             'BackgroundColor','white',...
             'Position',[.01 .01 0.98 0.99*sGens]);

%% 2.1 Empty plots within panels:
ax = cell(nGPlots+1,1);
ax{nGPlots+1} = axes(pCart,'Position',[0.1 0.15 0.8 0.75]);

C0 = [0.1 0.15];
C1 = C0;
for i = 1:nGPlots
    if nGPlots <= 4 && (nDoF ~= 1)
        C1 = C0 + (i-1)*[0.9 0]/nGPlots;
        ax{i} = axes(pGens,'Position',[C1 [0.8/nGPlots 0.8]]);
    elseif nGPlots > 4 && (nDoF ~= 1)                                       % Two rows once there are more than 4 plots
        if i <= 3
            C1 = C0 + (i-1)*[0.9/3 0] + [0 0.47];
            ax{i} = axes(pGens,'Position',[C1 ([0.8/3 0.8/2])]);
        else
            C1 = C0 + (i-4)*[0.9/3 0];
            ax{i} = axes(pGens,'Position',[C1 ([0.8/3 0.8/2])]);
        end
    else
        % Do nothing for nDoF = 1
    end
end

%% 3. Tags for GUI objects:
nTags = 10;                                                                 % Tags allow multiple GUIS to run at once
if evalin('base',"exist('Tags','var')")
    Tags = evalin('base','Tags');
    endTags = str2double(Tags{end});                                        % Continue with tag-names if plot already made before.
else
    endTags = 0;
end
Tags = cell(nTags,1);
for i = 1:nTags
    Tags{i} = num2str(endTags+i/nTags);
end
assignin('base','Tags',Tags);

%% 4. User Panel
%% 4.01 Pop-up menu for generator choice
uicontrol('Parent', pUser, 'Style', 'text',...
            'Position',[20 410 150 35],...
            'String','Selected Generator:');
GenChoice = uicontrol('Parent', pUser, 'Style', 'popupmenu','Tag',Tags{8},...
            'Position',[25 380 120 20]);
Choices = cell(nDoF,1);
for i = 1:nDoF
    Choices{i} = num2str(i);
end
GenChoice.String = Choices;                                                 % All generators that are for choice

%% 4.1 Slider for choice of pseudo energy
Slider = uicontrol('Parent',pUser,'Style','slider','Tag',Tags{1},...        % Slider position and value range
               'UserData',struct('val',2,'Handles',cell(1)),...
               'Position',[70,125,260,25],'value',2, 'min',2, 'max',...      % Ignore first point on generator, as it's numerical noise (E = 0)
               3,'SliderStep',[0.01 0.10]);

bgcolor = pUser.BackgroundColor;
uicontrol('Parent',pUser,'Style','text','Position',[30,120,25,25],...        % Lower Limit of slider
                'String','0 J','BackgroundColor',bgcolor);
MaxJ = uicontrol('Parent',pUser,'Style','text','Position',[330,120,70,25],...% Upper Limit of slider
                'String','Max J','BackgroundColor',bgcolor,'Tag', Tags{2});
CurJ = uicontrol('Parent',pUser,'Style','text','Position',[110,95,175,23],...% Description of Energy
                'String',sprintf('Energy in J'),'BackgroundColor',bgcolor,'Tag',Tags{3});

%% 4.2 Buttons: to save videos, truncate and save generators:

% Save video:
uicontrol('Parent', pUser, 'Style', 'text',...
            'Position',[20 220 150 25],...
            'String','Save Video of:');
SaveVideo = uicontrol('Parent', pUser, 'Style', 'popupmenu',...
            'Position',[20 180 180 30],'Tag', Tags{4});
Choices = {'Mode for current energy','Modes for current generator','Generator Evolution in Conf-space'};
SaveVideo.String = Choices;

% Truncate generators:

TruncateGen = uicontrol('Parent', pUser, 'Style', 'pushbutton',...
            'Position',[70,55,200,25],'Tag', Tags{9},'String','Truncate Generator');

% Save generators:

SaveRBig = uicontrol('Parent', pUser, 'Style', 'pushbutton',...
            'Position',[70,20,200,25],'Tag', Tags{10},'String','Save RBig');

%% 4.3 Toggle for potential, current mode, other generators
% 4.31 Potential
uicontrol('Parent', pUser, 'Style', 'text',...
            'Position',[20,315,150,35],...
            'String','Toggles for Plots:');
PotentialToggle = uicontrol('Parent', pUser, 'Style', 'checkbox',...
        'UserData',cell(1),...
        'Position',[20 270 150 15], 'Tag', Tags{5});
PotentialToggle.String = {'Potential'};

% 4.32 Current mode
ModeToggle = uicontrol('Parent', pUser, 'Style', 'checkbox',...
        'UserData',cell(1),...
        'Position',[20 285 150 15], 'Tag', Tags{6});
ModeToggle.String = {'Current Mode'};

% 4.33 Other generators
GeneratorToggle = uicontrol('Parent', pUser, 'Style', 'checkbox',...
        'UserData',cell(1),...
        'Position',[20,300,150,15], 'Tag', Tags{7});
GeneratorToggle.String = {'Other Generators'};

%% 5. Pre-select generator
selection(1,pUser,ax,RBig,Y,YCart,nGPlots,n3D,n2D,nDoF,nSearch,psi_e_inv,Tags);

end

%% 6. Update functions
function selection(kG,pUser,ax,RBig,Y,YCart,nGPlots,n3D,n2D,nDoF,nSearch,psi_e_inv,Tags,src, evnt)
    global FKIN_EXISTS;
    %% Adapt slider callback:
    [E_Max,~] = max(RBig{kG,3}(:,end));

    % Identify GUI objects via Tags
    Slider = findobj('Tag',Tags{1});
    MaxJ = findobj('Tag',Tags{2});
    CurJ = findobj('Tag',Tags{3});
    SaveVideo = findobj('Tag',Tags{4});
    PotentialToggle = findobj('Tag',Tags{5});
    ModeToggle = findobj('Tag',Tags{6});
    GeneratorToggle = findobj('Tag',Tags{7});
    GenChoice = findobj('Tag',Tags{8});
    truncateGenerator = findobj('Tag',Tags{9});
    SaveRBig = findobj('Tag',Tags{10});

    % Setting initial values for some GUI objects
    set(Slider,'max', size(RBig{kG,1},1));
    set(Slider,'value', size(RBig{kG,1},1));
    set(Slider,'SliderStep', [1/size(RBig{kG,1},1) 5/size(RBig{kG,1},1)]);
    Slider.UserData.val = Slider.Value;                                     % Also save current Slider value, e.g. for use in makevideo
    set(CurJ, 'String', sprintf('Pseudo-Energy %.2f J',E_Max));
    set(MaxJ, 'String', sprintf('%.2f J', E_Max));

    % Callbacks
    Slider.Callback = @(es,ed) SliderUpdate(floor(es.Value),ax,Y,YCart,kG,RBig,CurJ,nGPlots,n3D,nSearch,Tags);  % floor of slider value for appropriate index choice
    SaveVideo.Callback = @(es,ed) savevideo(Y,YCart,RBig,kG,Tags,es.Value,ax);
    PotentialToggle.Callback = @(es,ed) addPotential(es.Value,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
    ModeToggle.Callback = @(es,ed) addMode(es.Value,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
    GeneratorToggle.Callback = @(es,ed) addGenerators(es.Value,ax,Y,RBig,kG,nGPlots,nDoF,nSearch,n3D,Tags,psi_e_inv);
    GenChoice.Callback = @(es,ed) selection(es.Value,pUser,ax,RBig,Y,YCart,nGPlots,n3D,n2D,nDoF,nSearch,psi_e_inv,Tags);
    truncateGenerator.Callback = @(es,ed) truncateGeneratorFun(kG,pUser,ax,RBig,Y,YCart,nGPlots,n3D,n2D,nDoF,nSearch,psi_e_inv,Tags);
    SaveRBig.Callback = @(es,ed) saveRBigFun(RBig);
    %% Initial figures: plot in pCart (ax{end})
    if FKIN_EXISTS
        y = YCart{kG,1}{end};
        Legend = cell(nDoF,1);
        cla(ax{end});
        hold(ax{end},'on');
        colors = hsv(nDoF);
        y_prev = [0,0];                                                     % Position of mass of previous link
        for j = 1:nDoF
            plot(ax{end},y(:,(j-1)*2+1),y(:,(j-1)*2+2),'LineWidth',2,'Color',colors(j,:));
    %         Name = sprintf('Mass %i',j);
    %         Legend{j,1} = Name;
            y_new = [y(1,(j-1)*2+1),y(1,(j-1)*2+2)];
            scatter(ax{end},y_new(1),y_new(2),'filled', ...
                'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
            plot(ax{end},[y_prev(1),y_new(1)],[y_prev(2),y_new(2)],'LineWidth',1,'color','b');
            y_prev = y_new;
        end
        hold off
        axis(ax{end},'auto'); axis(ax{end},'equal');
        xlabel(ax{end},'x in m','interpreter', 'latex', 'FontSize',22)
        ylabel(ax{end},'y in m','interpreter', 'latex', 'FontSize',22)
%         xlim(ax{end},[-1.2,1.2]);
%         ylim(ax{end},[-0.4,2]);
        title(ax{end},sprintf('Modes on Generator %i',kG),'interpreter', 'latex', 'FontSize',18)
    %     hl = legend(ax{end},Legend);
    %     set(hl,'Interpreter','latex','location','southeast')%,'orientation','horizontal')
        set(ax{end}, 'TickLabelInterpreter', 'latex')
        grid(ax{end},'on'), box(ax{end},'on')
    end
    %% Initial figures: plots in pGens (ax{1} to ax{end-1})
    addGenerators(GeneratorToggle.Value,ax,Y,RBig,kG,nGPlots,nDoF,nSearch,n3D,Tags,psi_e_inv);
    addMode(ModeToggle.Value,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
    addPotential(PotentialToggle.Value,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
end

function [] = SliderUpdate(I,ax,Y,YCart,kG,RBig,TextHandle,nGPlots,n3D,nSearch,Tags)
global FKIN_EXISTS;
Slider = findobj('Tag',Tags{1});
Slider.UserData.val = I;                                                    % Save current slider to share with video button
PotentialToggle = findobj('Tag',Tags{5});
PotentialToggle = PotentialToggle.Value;
ModeToggle = findobj('Tag',Tags{6});
ModeToggle = ModeToggle.Value;

%% Redraw pCart:
if FKIN_EXISTS
    cla(ax{end});                                                           % Clears data from plot
    nDoF = size(YCart,1);
    colors = hsv(nDoF);
    y = YCart{kG,1}{I};
    % Legend = cell(nDoF,1);
    hold(ax{end},'on')                                                      % Keep Axis Labels
    y_prev = [0,0];                                                         % Position of mass of previous link
    for j = 1:nDoF
        plot(ax{end},y(:,(j-1)*2+1),y(:,(j-1)*2+2),'LineWidth',2,'color',colors(j,:));  % Updates with new trajectory
    %     Name = sprintf('Mass %i',j);
    %     Legend{j,1} = Name;
        y_new = [y(1,(j-1)*2+1),y(1,(j-1)*2+2)];
        scatter(ax{end},y_new(1),y_new(2),'filled', ...
            'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
        plot(ax{end},[y_prev(1),y_new(1)],[y_prev(2),y_new(2)],'LineWidth',1,'color','b');
        y_prev = y_new;
    end
    hold off
    % legend(ax{end},Legend)
else
    nDoF = nSearch+1;
end
E = RBig{kG,1}(I,end);
if size(RBig,2) == 3                                                        % Cases, if natural continuation is used
    EAbs = RBig{kG,3}(I,end);
else
    EAbs = E;
end
TextHandle.String = sprintf('Pseudo-Energy: %.2f J', EAbs);

%% Redraw (mode in) pGens:
addMode(ModeToggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
addPotential(PotentialToggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
end

function [] = savevideo(Y,YCart,RBig,kG,Tags,String,ax)
global FKIN_EXISTS;
if ~FKIN_EXISTS
    if String == 1 || String == 2
        String = 0;
        fprintf("Forward kinematics of .urdf file missing in Matlab")
    end
end

if String == 1                                                              % Mode for current energy
    videoCart_Mode(YCart,RBig,kG,Tags);
elseif String == 2                                                          % Modes for current generator
    videoCart_Gen(YCart,RBig,kG);
elseif String == 3                                                          % Generator Evolution in Conf-space
    videoConf_Gen(Y,RBig,kG,Tags,ax);
end
end

function [] = addPotential(Toggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags)
    Slider = findobj('Tag',Tags{1});
    I = Slider.UserData.val;
    h = findobj('Tag',Tags{5});
    PotHandles = h.UserData;                                                % Handles of Potential Surfaces

    for i = 1:size(PotHandles,1)
        delete(PotHandles{i});                                              % Delete previous potential surfaces
    end
    PotHandles = cell(nGPlots,1);
    if Toggle
        lower = 1;
        for k = 1:nGPlots
            hold(ax{k},'on')
            x = Y{kG,1}{I}(1,1:nDoF)';
            if (nDoF == 2)
              xl = ax{k}.XLim; yl = ax{k}.YLim;
              q1 = linspace(xl(1), xl(2), 100); q2 = linspace(yl(1), yl(2), 100);
              [Q1, Q2] = meshgrid(q1, q2);
              Pot = zeros(size(Q1));
              for i = 1:size(Q1, 1)
                for j = 1:size(Q1, 2)
                  Pot(i,j) = V([Q1(i,j); Q2(i,j)], 0);
                end
              end
              [~, PotHandles{k}] = contour(ax{k},Q1,Q2,Pot,20, 'DisplayName', 'Potential');
            elseif (nDoF >1)
                H = nDoF_LevelSet(x,lower,lower+1+(k<=n3D));
                PotHandles{k} = plotPlane(H,x,lower,lower+1+(k<=n3D),ax{k});
                lower = lower + 2 + (k<=n3D);
            end
        end
        hold off
    end
    h.UserData = PotHandles;
end

function [ModeHandles] = addMode(Toggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags)
Slider = findobj('Tag',Tags{1});
I = Slider.UserData.val;                                                    % Retrieve current slider value
E = RBig{kG,1}(I,end);
lower = 1;
ModeHandles = Slider.UserData.Handles;                                      % Labels of modes, not generators
for i = 1:size(ModeHandles,1)
    delete(ModeHandles{i});
end
ModeHandles = cell(nGPlots,1);
if Toggle
    for k = 1:nGPlots
        hold(ax{k},'on')
        if (k <=n3D) && (nDoF > 1)
            ModeHandles{k} = plot3(ax{k},Y{kG}{I}(:,lower),Y{kG}{I}(:,lower+1),Y{kG}{I}(:,lower+2),'LineWidth',1,'color','#77AC30');                                    % Updates with new trajectory
            lower = lower + 3;
        elseif (k > n3D) && (nDoF >1)
            ModeHandles{k} = plot(ax{k},Y{kG}{I}(:,lower),Y{kG}{I}(:,lower+1),'LineWidth',1,'color','#77AC30');
            lower = lower + 2;
        end
        legend(ModeHandles{k},sprintf('E = %2.f', E));
    end
    hold off
end
Slider.UserData.Handles = ModeHandles;
end

function [] = addGenerators(Toggle,ax,Y,RBig,kG,nGPlots,nDoF,nSearch,n3D,Tags,psi_e_inv)
    GeneratorToggle = findobj('Tag',Tags{7});
    GeneratorSelection = findobj('Tag',Tags{8});
    GeneratorHandles = plotGenerators_nDoF(ax,RBig,nGPlots,n3D,nSearch,nDoF,psi_e_inv);
    if Toggle
        IJK = size(GeneratorHandles);
        for i = 1:IJK(1)
            for j = 1:IJK(2)
                if size(IJK,2) == 3
                    for k = 1:IJK(3)
                        if j ~= GeneratorSelection.Value
                            delete(GeneratorHandles{i,j,k});
                        end
                    end
                else
                    if j ~= GeneratorSelection.Value
                            delete(GeneratorHandles{i,j});
                    end
                end
            end
        end
    end
    PotentialToggle = findobj('Tag',Tags{5});
    PotentialToggle = PotentialToggle.Value;
    ModeToggle = findobj('Tag',Tags{6});
    ModeToggle = ModeToggle.Value;
    GeneratorToggle.UserData = GeneratorHandles;
    addMode(ModeToggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
    addPotential(PotentialToggle,ax,Y,RBig,kG,nGPlots,nDoF,n3D,Tags);
end


function truncateGeneratorFun(kG,pUser,ax,RBig,Y,YCart,nGPlots,n3D,n2D,nDoF,nSearch,psi_e_inv,Tags)
    Slider = findobj('Tag',Tags{1});
    I = Slider.UserData.val;                                                % Retrieve current slider value
    EAbs = RBig{kG,3}(I,end);
    RBig = truncateRBig(RBig,kG,EAbs);
    NewSize = size(RBig{kG,1},1);
    for i = 1:4                                                             % Also truncate Y and YCart
        Y{kG,i} = Y{kG,i}(1:NewSize);
    end
    for i = 1:2
        YCart{kG,i} = YCart{kG,i}(1:NewSize);
    end
    selection(kG,pUser,ax,RBig,Y,YCart,nGPlots,n3D,n2D,nDoF,nSearch,psi_e_inv,Tags);
end

function saveRBigFun(RBig)
    save('RBig_New','RBig');
end
