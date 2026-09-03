% dc

%load M.mat
%load R
% M_robot = load(['Manifold/M.mat']);
% R_robot = load(['Manifold/R.mat']);
% M1 = M_robot.M; 
% R = R_robot.R;
% 
% % demo_Spatial
% global eig_rng
% eig_rng = 1:6;

% simulation
i_x = 1:6;
i_dx = 7:12;
f = @(t,X) [X(i_dx); M(X)^-1*( -C(X)*X(i_dx) -g(X) -spring(X) )];


% IC
% from tool using chosen eigenmode and unit disk parametrization
eigenmode1 =  eig_rng(1);
eigenmode2 =  eig_rng(2); 
%
%sz1 = size(R{eigenmode1}.generator,1)-1;
energy_rng_idx1 = R{eigenmode1}.pseudo_energy < 0.3;
sz1 = sum(energy_rng_idx1);
X_orbits_eig1 = cell(sz1,1);

for i = 1:sz1
    X0_i = [R{eigenmode1}.generator(i,:)'; zeros(6,1)];
    t_end = R{eigenmode1}.periods(end)*1.03;
    timespan = linspace(0, t_end, 2e2);
    [T_sim, X_sim] = ode45(f, timespan, X0_i);
    X_orbits_eig1{i} = X_sim;
end
sz2 = size(R{eigenmode2}.generator,1)-1;
X_orbits_eig2 = cell(sz2,1);
for i = 1:sz2
    X0_i = [R{eigenmode2}.generator(i,:)'; zeros(6,1)];
    t_end = R{eigenmode2}.periods(end)*1.006;
    timespan = linspace(0, t_end, 2e2);
    [T_sim, X_sim] = ode45(f, timespan, X0_i);
    X_orbits_eig2{i} = X_sim;
end

%%
% xlabel(['q_{',num2str(d1),'}'], 'FontSize', 20)
% ylabel(['q_{',num2str(d2),'}'], 'FontSize', 20)
% zlabel(['q_{',num2str(d3),'}'], 'FontSize', 20)

%% proj plots 1
d1 = 2;
d2 = d1+6;
d3 = 3;
f1=figure(1); clf; hold on; grid on
f1.Position = [0,0,600,600];
id1=0;
for orbit = X_orbits_eig1'
    id1=id1+1;
    c = [0.5,0.9,0.5]*sqrt((sz1+1-id1)/(sz1));
    plot3(orbit{1}(:,d1),orbit{1}(:,d2),orbit{1}(:,d3), 'Color', c, 'LineWidth',2)
end
x_d1=[];x_d2=[];x_d3=[];cc=[];
for orbit = X_orbits_eig1(1:end)'
    x_d1 = [x_d1, orbit{1}(:,d1)];
    x_d2 = [x_d2, orbit{1}(:,d2)];
    x_d3 = [x_d3, orbit{1}(:,d3)];
    cc = [cc, ones(size(orbit{1},1),3)*i/length(orbit{1})];
end

surf(x_d1,x_d2,x_d3,'EdgeAlpha',0, 'FaceAlpha',0.5,'FaceColor',[0.8,1,0.8]*0.75)
xlabel('$y$','Interpreter','latex', 'FontSize', 24)
ylabel('$\dot{y}$','Interpreter','latex', 'FontSize', 24)
zlabel('$z$','Interpreter','latex', 'FontSize', 24)
view(3)

%% proj plots 2
d1 = 1;
d2 = d1+6;
d3 = 3;
f2=figure(2); clf; hold on; grid on
f2.Position = [0,0,600,600];
id2=0;
for orbit = X_orbits_eig2'
    id2=id2+1;
    c = [0.9,0.5,0.5]*sqrt((sz2+1-id2)/(sz2));
    plot3(orbit{1}(:,d1),orbit{1}(:,d2),orbit{1}(:,d3), 'Color', c, 'LineWidth',2)
end
x_d1=[];x_d2=[];x_d3=[];cc=[];
for orbit = X_orbits_eig2(1:end)'
    x_d1 = [x_d1, orbit{1}(:,d1)];
    x_d2 = [x_d2, orbit{1}(:,d2)];
    x_d3 = [x_d3, orbit{1}(:,d3)];
    cc = [cc, ones(size(orbit{1},1),3)*i/length(orbit{1})];
end
surf(x_d1,x_d2,x_d3,'EdgeAlpha',0, 'FaceAlpha',0.5,'FaceColor',[1,0.8,0.8]*0.75)
xlabel('$x$','Interpreter','latex', 'FontSize', 24)
ylabel('$\dot{x}$','Interpreter','latex', 'FontSize', 24)
zlabel('$z$','Interpreter','latex', 'FontSize', 24)
view(3)



