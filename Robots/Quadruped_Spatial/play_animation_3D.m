% dc
load robot.mat
%% setup
make_video = 0;
gy = 0.5*[1 1 1];

hFig = figure(20);
clf

% fig settings
hFig.Position(3:4) = [400, 200]*2;
com_size = 150;
% select input simualation data
X_anim = X_sim;
t_span = T_sim;
n = size(X_anim,2)/2;
%
dim = length(X_anim); % state
f = ceil(0.01/(t_span(2)-t_span(1)));
dt = (t_span(2)-t_span(1))*f;

% extract ? todo
r0 = 2*0.12*cosd(25);
k = 3.0; % SEA joint stiffness
L = [0.1650; 0.09; 0.02];
l = 0.12;
h = 0.03; %0.03;
y_ext = 1.0;
qj0_leg = 0.5*acos(r0^2/(2*l^2)-1);
clear cm

X_ts = [];

loops = floor(dim/f);
% frames for movie
if make_video
    clear F %#ok<*UNRCH>
    F(ceil(loops+1)) = struct('cdata',[],'colormap',[]);
    v = VideoWriter(['eig' num2str(eigenmode) '_anim.avi']);
    open(v);
end

% UI
global global_anim_stop
global_anim_stop = false;

% get com
cm = {};
for i = 1:loops
    X_i  = X_anim(i*f, 1:n)';
    com = fKin(X_i);
    v_com = com;
    cm{i} = v_com; %#ok<SAGROW>
end

% pre-plots
if isvalid(hFig)
    figure(20)
    clf
    hold on
    grid on
    axis equal
    box on
    % plot com
    cm_ts = [cm{:}];
    plot3(cm_ts(1,:), cm_ts(2,:), cm_ts(3,:),':k', 'LineWidth', 1.25)
    % LABELS
    xlabel('$x$ [m]', 'interpreter', 'latex', 'FontSize', LABEL_FONT_SIZE)
    ylabel('$y$ [m]', 'interpreter', 'latex', 'FontSize', LABEL_FONT_SIZE)
    zlabel('$z$ [m]', 'interpreter', 'latex', 'FontSize', LABEL_FONT_SIZE)
end

%% loop anim
for i = 1:loops
    tic
    % collect config
    X_i  = X_anim(i*f, 1:n)';
    % get data
    v_com = fKin(X_i);
    % IK
%     qj_i = qj_ik_fcn(X_i, L, h, l);
    base_Htm_o = ([o_Htm_BASE_fcn(X_i); 0 0 0 1 ])^-1;
    base_Htm_o = base_Htm_o(1:3,:);
    qj_i = qj_ik_fcn(base_Htm_o);
    
    qj = qj_i;
    % coupling
    qj(1) = -qj(1);
    qj(7) = -qj(7);
    
    qj(3) = qj_i(3) - qj_i(2);
    qj(6) = qj_i(6) - qj_i(5);
    qj(9) = qj_i(9) - qj_i(8);
    qj(12) = qj_i(12) - qj_i(11);
    
    X_ts(i,:) = [X_i; -qj]';
     
%     [xg,Htm,~,~,~,~,~,~,~,~,~] = KaneScrew( 0, 1, robot.parent, robot.g0, robot.csi, robot.com, robot.Mass, [X_i; -qj], zeros(18,1));
    
    Htm = Htm_full_fcn(X_i, qj);
    
    get_pos_at_tcp = @(tcp) Htm(4*tcp+(1:3), 4);

    vFR_hip = get_pos_at_tcp(robot.tcp(2));
    vFR_knee = get_pos_at_tcp(robot.tcp(3));
    vFR_foot = get_pos_at_tcp(robot.tcp(4));
    
    vFL_hip = get_pos_at_tcp(robot.tcp(8));
    vFL_knee = get_pos_at_tcp(robot.tcp(9));
    vFL_foot = get_pos_at_tcp(robot.tcp(10));
    
    vHR_hip = get_pos_at_tcp(robot.tcp(11));
    vHR_knee = get_pos_at_tcp(robot.tcp(12));
    vHR_foot = get_pos_at_tcp(robot.tcp(13));
    
    vHL_hip = get_pos_at_tcp(robot.tcp(5));
    vHL_knee = get_pos_at_tcp(robot.tcp(6));
    vHL_foot = get_pos_at_tcp(robot.tcp(7));

    % exit
    if not(isvalid(hFig)) || (v_com(3) < 0) || global_anim_stop
        disp('Animation stopped.')
        break;
    end
    
    % clear plot area
    figure(20)
    % setup window
    
    % plot
    if not(exist('h_com','var')) || not(isvalid(h_com))
                 xlim([-0.5,  0.5])
                 ylim([-0.3 0.3])
                 zlim([-0.1*0 0.3])
                view(45,30)
        
        plot3(L(1),L(2)*y_ext,0,'ko');
        plot3(L(1),-L(2)*y_ext,0,'ko');
        plot3(-L(1),L(2)*y_ext,0,'ko');
        plot3(-L(1),-L(2)*y_ext,0,'ko');
        
        h_body_FL = line([v_com(1),vFL_hip(1)], [v_com(2),vFL_hip(2)], [v_com(3),vFL_hip(3)], 'color', 'r', 'linewidth', 2);
        h_body_FR = line([v_com(1),vFR_hip(1)], [v_com(2),vFR_hip(2)], [v_com(3),vFR_hip(3)], 'color', 'g', 'linewidth', 2);
        h_body_HL = line([v_com(1),vHL_hip(1)], [v_com(2),vHL_hip(2)], [v_com(3),vHL_hip(3)], 'color', 'y', 'linewidth', 2);
        h_body_HR = line([v_com(1),vHR_hip(1)], [v_com(2),vHR_hip(2)], [v_com(3),vHR_hip(3)], 'color', 'm', 'linewidth', 2);
        h_com = scatter3(v_com(1), v_com(2), v_com(3), com_size, 'MarkerFaceColor', gy,'MarkerEdgeColor', gy, 'MarkerEdgeAlpha', 0);

        
        h_hip_HR = line([vHR_hip(1),vHR_knee(1)], [vHR_hip(2),vHR_knee(2)], [vHR_hip(3),vHR_knee(3)], 'color', 'k', 'linewidth', 2);
        h_shank_HR = line([vHR_knee(1),vHR_foot(1)], [vHR_knee(2),vHR_foot(2)], [vHR_knee(3),vHR_foot(3)], 'color', 'k', 'linewidth', 2);
        
        h_hip_FL = line([vFL_hip(1),vFL_knee(1)], [vFL_hip(2),vFL_knee(2)], [vFL_hip(3),vFL_knee(3)], 'color', 'k', 'linewidth', 2);
        h_shank_FL = line([vFL_knee(1),vFL_foot(1)], [vFL_knee(2),vFL_foot(2)], [vFL_knee(3),vFL_foot(3)], 'color', 'k', 'linewidth', 2);
        
        h_hip_HL = line([vHL_hip(1),vHL_knee(1)], [vHL_hip(2),vHL_knee(2)], [vHL_hip(3),vHL_knee(3)], 'color', 'k', 'linewidth', 2);
        h_shank_HL = line([vHL_knee(1),vHL_foot(1)], [vHL_knee(2),vHL_foot(2)], [vHL_knee(3),vHL_foot(3)], 'color', 'k', 'linewidth', 2);
        
        h_hip_FR = line([vFR_hip(1),vFR_knee(1)], [vFR_hip(2),vFR_knee(2)], [vFR_hip(3),vFR_knee(3)], 'color', 'k', 'linewidth', 2);
        h_shank_FR = line([vFR_knee(1),vFR_foot(1)], [vFR_knee(2),vFR_foot(2)], [vFR_knee(3),vFR_foot(3)], 'color', 'k', 'linewidth', 2);

    else
        % update handles
%         tic
        assign_XYZData(h_com, v_com);
        assign_XYZData(h_body_FL, [v_com, vFL_hip]);
        assign_XYZData(h_body_FR, [v_com, vFR_hip]);
        assign_XYZData(h_body_HL, [v_com, vHL_hip]);
        assign_XYZData(h_body_HR, [v_com, vHR_hip]);
        
        assign_XYZData(h_hip_HR, [vHR_hip, vHR_knee]);
        assign_XYZData(h_shank_HR, [vHR_knee, vHR_foot]);
        assign_XYZData(h_hip_HL, [vHL_hip, vHL_knee]);
        assign_XYZData(h_shank_HL, [vHL_knee, vHL_foot]);
        assign_XYZData(h_hip_FR, [vFR_hip, vFR_knee]);
        assign_XYZData(h_shank_FR, [vFR_knee, vFR_foot]);
        assign_XYZData(h_hip_FL, [vFL_hip, vFL_knee]);
        assign_XYZData(h_shank_FL, [vFL_knee, vFL_foot]);
%         toc
    end
    % update
%     tic
    drawnow
%     toc
    t_draw = toc;
    
    if make_video
        % save frames in AVI
        F(i) = getframe(gcf) ;
        writeVideo(v, F(i));
    end
end

if make_video
    % save and close AVI
    F(i+1) = getframe(gcf)
    writeVideo(v, F(i+1));
    close(v)
end
