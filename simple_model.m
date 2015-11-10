function R = simple_model(pIn, d)
% ODE Predator-prey interaction model (no longer so "simple")


%% Parameters

% Scaling constants
sT = pIn.param.sT;
sL = pIn.param.sL;

% Convert parameter values, according to scaling constants
p = convert_params(pIn,d);

% Define simulation type
p.param.sim_type = pIn.param.sim_type;

% Set default simType
if nargin < 3
    simType = 'default';
end

p.simType = simType;


%% Configure solver

% Solver options
options  = odeset('RelTol',p.param.rel_tol,...
                  'AbsTol',p.param.abs_tol, ...
                  'Events',@capture_fnc, ...
                  'MaxStep',p.param.max_step);
                          
              
%% Solve & save results in SI units

global captured
captured = 0;

% Run solver
[t,X,t_event] = solver(p,options);

% Results stored in SI units 
R.t             = t         .* sT;
R.X(:,1)        = X(:,1)    .* sL;
R.X(:,2)        = X(:,2)    .* sL;
R.X(:,3)        = X(:,3);
R.X(:,4)        = X(:,4)    .* sL;
R.X(:,5)        = X(:,5)    .* sL;
R.X(:,6)        = X(:,6);
R.capture       = captured;

%clear capture

% Same data, with field names
R.tEnd          = t_event   .* sT;
R.xPrey         = X(:,1)    .* sL;
R.yPrey         = X(:,2)    .* sL;
R.thetaPrey     = X(:,3);
R.xPred         = X(:,4)    .* sL;
R.yPred         = X(:,5)    .* sL;
R.thetaPred     = X(:,6);


%% Solver

function [t,X,t_event] = solver(p,options)
% Numerical integration of the trajectory of predator and prey

X0(1,1) = p.prey.x0;
X0(2,1) = p.prey.y0;
X0(3,1) = p.prey.theta0;
X0(4,1) = p.pred.x0;
X0(5,1) = p.pred.y0;
X0(6,1) = p.pred.theta0;

% Intialize global status on a capture
% Declare global variable
    %global stopsim captured
stopsim  = 0;
captured = 0;

% Intitialize state variables
%s = give_behavior('Initialize', p);
s = [];

% RUN SOLVER --------------------------------------------------------------

% Runge-Kutta solver
[t,X,t_event] = ode45(@gov_eqn,p.param.t_span,X0,options);

    function dX = gov_eqn(t,X)
    % ODE for the dynamics of the system
        
        % BEHAVIORAL CHANGES ----------------------------------------------
        s = give_behavior(p.param.sim_type, p, s, t, X);

        % Update global 'captured' variable
        captured = s.prey.captured;
        stopsim = s.stopsim;      
        
        % OUTPUTS ---------------------------------------------------------
        
        % Prey velocity in x & y directions
        dX(1,1) = s.prey.spd * cos(s.prey.theta);
        dX(2,1) = s.prey.spd * sin(s.prey.theta);
        
        % Prey rate of rotation
        dX(3,1) = s.prey.omega;
       
        % Predator velocity in x & y directions
        dX(4,1) = s.pred.spd * cos(s.pred.theta);
        dX(5,1) = s.pred.spd * sin(s.pred.theta);
        
        % Predator rate of rotation 
        dX(6,1) = s.pred.omega;

    end
end


%% CAPTURE FUNCTION: use with 'Event' option in ode45 ----------------------
function [value, isterminal, direction] = capture_fnc(~,X)
    
    % Declare global variable
    global stopsim %captured
    
    % the event occurs when distance is less than capture distance
    %distance = hypot(X(4)-X(1),X(5)-X(2));
    if stopsim %|| (X(4)>X(1))
        %distance < p.param.d_capture
        value      = 0;
        isterminal = 1;         % tells ode45 to stop integration
        direction  = 0;
    else
        value = 1;
        isterminal = 0;         
        direction  = 0;
   end
end


function vis_instant(s,p)
% Look at state of predtaor and prey (for troubleshooting)  

    % Number of points for the wall 
    num_pts = 200;
    
    % Radial coordinates for the wall
    phi = linspace(0,2*pi,500);

    % Extract wall radius 
    r = p.param.tank_radius;
    
    % Get limits
    xlims(1) = -r * 1.1;
    xlims(2) =  r * 1.1;
    ylims(1) = -r * 1.1;
    ylims(2) =  r * 1.1;


    figure
    clrs = get(gca,'ColorOrder');
    
    % Draw walls
    h2 = plot(r.*cos(phi),r.*sin(phi),'-k');
    hold on
    
    % Render predator
    hB(1) = fill(s.pred.xBodG,s.pred.yBodG,clrs(2,:));
    set(hB(1),'EdgeColor','none')

    % Render prey
    hB(2) = fill(s.prey.xBodG,s.prey.yBodG,clrs(1,:));
    set(hB(2),'EdgeColor','none')

    % Render suction field
    bS = plot(s.pred.xSuc, s.pred.ySuc,'k');
    
    % Removed axes
    set(gca,'Box','off')
    set(gca,'XColor','w')
    set(gca,'YColor','w')
    
    axis equal
    hold off
end

end