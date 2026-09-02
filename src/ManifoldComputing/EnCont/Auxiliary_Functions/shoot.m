function [u,t] = shoot(u0,T,type,options)
%SHOOT With u' = T*f(u), u(0) = u0, returns u(1) or u(t), for type = 'end', 'full' or 'EoM', 'Viewer' 
%   f is constructed from the 2nd order system specified by EoM in the
%   folder 'Specific Systems'. If type = 'EoM', then u = du/dt(t=0) is returned
%   and t = 0. For type = 'Viewer', the results are for urdf files are shown in
%   a viewer. Field robot_model is only used if type = 'Viewer

global Simulator; % Simulink, Luca, Standard, C++ - set inMS.m 

if Simulator == "Simulink" || Simulator == "Luca"   
    if Simulator == "Luca"
        mdl = 'Luca';
        FastRestart = "off";
    elseif Simulator == "Simulink"
        mdl = 'Dynamics';
        FastRestart = "on";
    end
    x0 = u0(1:end/2);
    dx0 = u0(end/2+1:end);
    load_system(mdl)
    hws = get_param(mdl, 'modelworkspace');
    hws.assignin('T', T);
    hws.assignin('x0', x0);
    hws.assignin('dx0', dx0);
    set_param(mdl,'FastRestart', FastRestart);
    in = Simulink.SimulationInput(mdl);
    in = in.setModelParameter('AbsTol',num2str(options.AbsTol)); %'SimulationMode', 'accelerator'
    in = in.setModelParameter('RelTol',num2str(options.RelTol)); %'SimulationMode', 'accelerator'
    in.applyToModel;
    simOut = sim(in);
end

if type == "end"
    if Simulator == "Standard"
        u = deval(ode45(@(t,u)EoM(u,T),[0 1],u0,options),1);
    elseif Simulator == "Simulink" || Simulator == "Luca"
        x = simOut.x_ev.signals.values(end,:)';
        dx = simOut.dx_ev.signals.values(end,:)';                         
        u = [x;dx];
    elseif Simulator == "C++"
        dyn = evalin('base','dyn');
        u_py = dyn.solve(mat2numpy(u0(1:end/2)),mat2numpy(u0(end/2+1:end)),T,options.AbsTol, int16(0));
        u = numpy2mat(u_py);
    end
    t = 1;    
elseif type == "full"
    if Simulator == "Standard"
        [t,u] = ode45(@(t,u)EoM(u,T),[0 1],u0,options);
    elseif Simulator == "Simulink" || Simulator == "Luca"
        x = simOut.x_ev.signals.values';
        dx = simOut.dx_ev.signals.values';                                
        u = [x;dx]';
        t = simOut.tout;
    elseif Simulator == "C++"
        dyn = evalin('base','dyn');
        u_py = dyn.solve(mat2numpy(u0(1:end/2)),mat2numpy(u0(end/2+1:end)),T,options.AbsTol, int16(1));
        u = numpy2mat(u_py);
        t = u(:,end)/T;
        u = u(:,1:end-1);
    end
elseif type == "EoM"
    if Simulator == "Standard" || Simulator == "Simulink"
        u = EoM(u0,T);
        u = u(end/2+1:end);
    elseif Simulator == "Luca"
        u = simOut.ddx_ev.signals.values(1,:)';  
    end
elseif type == "Viewer"
    if Simulator == "Luca" || Simulator == "Simulink"
        robot_model = evalin('base','robot_model');
        LucaDynamicsViewer( robot_model, simOut.tout, simOut.x_ev.signals.values );
    elseif Simulator == "Standard"
        robot_model = evalin('base','robot_model');
        [t,u] = ode45(@(t,u)EoM(u,T),[0 1],u0,options);
        LucaDynamicsViewer( robot_model, t, u(:,1:end/2) );
    elseif Simulator == "C++"
        robot_model = evalin('base','robot_model');
        dyn = evalin('base','dyn');
        u_py = dyn.solve(mat2numpy(u0(1:end/2)),mat2numpy(u0(end/2+1:end)),T,options.AbsTol, int16(1));
        u = numpy2mat(u_py);
        t = u(:,end)/T;
        u = u(:,1:end-1);
        LucaDynamicsViewer( robot_model, t, u(:,1:end/2) );
    end
end
end

