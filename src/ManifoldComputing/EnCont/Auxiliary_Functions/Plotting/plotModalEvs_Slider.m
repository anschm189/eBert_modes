%% Plot evolutions in modal coordinates for arbitrary nDoF
% Provides a slider to chose up to which energy level these are plotted

fig = plotModalEvs(Y,RBig,nDoF,p);                                          % Figures 
b = cell(nDoF,1);                                                           % GUIs


for i = 1:nDoF
    kG = i;
    I = size(RBig{kG,1},1);                                                 % Example Mode: kG-th Generator, index along Generator = I
    y = Y{kG}{I};
    
    %% Initial Figure
    [E_Max,Ind] = max(RBig{kG,1}(:,end));
    
    %% GUI, especially for slider
    b{i} = uicontrol('Parent',fig{i},'Style','slider','Position',...        % Slider position and value range
                  [81,54,419,23],'value',I, 'min',2, 'max',...              % Ignore first point on generator, as it's numerical noise (E = 0)
                  size(RBig{kG,1},1));                    
    bgcolor = fig{i}.Color;
    uicontrol('Parent',fig{i},'Style','text','Position',[50,54,23,23],...   % Left description of slider
                    'String','0 J','BackgroundColor',bgcolor);              
    uicontrol('Parent',fig{i},'Style','text','Position',[500,54,30,23],...  % Right description of slider
                    'String',join([num2str(floor(E_Max)),' J']),...
                    'BackgroundColor',bgcolor);
    TextHandle = uicontrol('Parent',fig{i},'Style','text','Position',[240,25,100,23],... % Description of slider
                    'String',sprintf('Energy %.2f J',E_Max),'BackgroundColor',bgcolor);
    b{i}.Callback = @(es,ed) updateSystem(floor(es.Value),Y,kG,RBig,TextHandle,p);    % floor of slider value for appropriate index choice
end

%% Update Function
function [] = updateSystem(I,Y,kG,RBig,TextHandle,p)
cla;                                                                        % Clears data from plot
hold on                                                                     % Plot all modal evolutions for the current generator
for k = 1:floor(I/p)
    yM = Y{kG,2}{k*p}(:,1);
    dyM = Y{kG,2}{k*p}(:,2);
    EPot = Y{kG,2}{k*p}(:,3);
    plot3(yM,dyM,EPot);
end
hold off                                                                    % Updates with new trajectory
E = RBig{kG,1}(I,end);
TextHandle.String = sprintf('Energy: %.2f J', E);

end
