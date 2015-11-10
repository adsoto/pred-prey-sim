function [p,d] = default_params
% Default parameter values for the predator, prey, tank, and solver


%% General parameters

% Tank dimension
p.param.tank_radius     = 10e-2;     % m
d.param.tank_radius     = 'L';


%% Solver parameters

% Time span for simulation
p.param.t_span        = [0 5];     % s
d.param.t_span      = 'T';

% Relative tolerance (applies to all components of the solution vector)
p.param.rel_tol     = 1e-3;
d.param.rel_tol     = '';

% Absolute tolerance (applies to individual components of solution vector)
p.param.abs_tol     = 1e-5;
d.param.abs_tol     = '';

% Scaling constants (helps the solver avoid crazy numbers)
p.param.sL      = 2e-2;   % m
d.param.sL      = 'L';

p.param.sT      = 1;      % s
d.param.sT      = 'T';

p.param.sim_type = 'default';
d.param.sim_type = '';


%% Prey parameters  

% Initial body position & orientation 
p.prey.x0           = -1e-2;      % m          
d.prey.x0           = 'L';

p.prey.y0           = 0; %-1e-2;      % m    
d.prey.y0           = 'L';

p.prey.theta0         = (90-60)/180*pi; % rad    
d.prey.theta0         = '';

% Initial speed
p.prey.spd0           = 0.15e-2;    % m/s
d.prey.spd0           = 'L/T';

% Escape parameters
% threshold distance for escape initiation 
p.prey.thrshEscape    = 1e-2;       % m
d.prey.thrshEscape    = 'L';

% speed during escape response
p.prey.spdEscape      = 3e-2;       % m/s  
d.prey.spdEscape      = 'L/T';

% turning rate during escape
p.prey.rotSpdEscape   = 25;         % rad/s
d.prey.rotSpdEscape   = '1/T';

p.prey.spdResp        = 2e-2;       % m/s
d.prey.spdResp        = 'L/T';

% response latency
p.prey.lat            = 4e-3;       % s
d.prey.lat            = 'T';

% time to complete turn during escape
p.prey.durEscape      = 40e-3;      % s
d.prey.durEscape      = 'T';

% Morphometrics
p.prey.bod_len        = 3.5e-3;           % m
d.prey.bod_len        = 'L';

p.prey.bod_width      = 0.5e-3;           % m
d.prey.bod_width      = 'L';

p.prey.COM_len        = p.prey.bod_len/4;   % m
d.prey.COM_len        = 'L';

p.prey.numBodPts      = 200;
d.prey.numBodPts      = '';

% Interval between start of saccades
p.prey.sccd_intvl   = 4;         % s
d.prey.sccd_intvl   = 'T';

% Duration of a saccade
p.prey.sccd_prd     = 0.25;       % s
d.prey.sccd_prd     = 'T';

% Peak rate of rotation during saccade
p.prey.sccd_omega      = 4;         % rad/s
d.prey.sccd_omega      = '1/T';

% Peak rate of rotation encounter with wall
p.prey.wall_omega       = 30;         % rad/s
d.prey.wall_omega       = '1/T';

% Proportion region beyond head for responding to walls
p.prey.fieldSize     = p.prey.bod_width * 2;  % m
d.prey.fieldSize     = 'L';


%% Predator parameters

% Initial body position & orientation 
p.pred.x0             = 0e-2;         % m  
d.pred.x0             = 'L';

p.pred.y0               = 0e-2;         % m      
d.pred.y0               = 'L';

p.pred.theta0           = 1*pi/4;      % rad  
d.pred.theta0           = '';

% Initial speed
p.pred.spd0             = 2e-2;      % m/s 
d.pred.spd0             = 'L/T';

% Interval between start of saccades
p.pred.sccd_intvl       = 2;         % s
d.pred.sccd_intvl       = 'T';

% Duration of a saccade
p.pred.sccd_prd         = 0.5;       % s
d.pred.sccd_prd         = 'T';

% Peak rate of rotation during saccade
p.pred.sccd_omega       = 3;         % rad/s
d.pred.sccd_omega       = '1/T';

% Peak rate of rotation encounter with wall
p.pred.wall_omega       = 6;         % rad/s
d.pred.wall_omega       = '1/T';

% Width of head
p.pred.bod_width        = 0.3e-2;    % m
d.pred.bod_width        = 'L';

p.pred.bod_len          = 2e-2;      % m
d.pred.bod_len          = 'L';

p.pred.numBodPts        = p.prey.numBodPts;
d.pred.numBodPts        = '';

% Position of COM
p.pred.COM_len        = p.pred.bod_len/4; % m 
d.pred.COM_len        = 'L';

% Distance for sensing walls
p.pred.fieldSize       = p.pred.bod_width * 3;  % m
d.pred.fieldSize       = 'L';

% Distance from prey for initiating a strike
p.pred.strike_thresh  = 1e-2;  % m
d.pred.strike_thresh  = 'L';

% Strike duration
p.pred.strike_dur     = 30e-3; % s
d.pred.strike_dur     = 'T';

% Maximum distance of capture
p.pred.strike_reach   = 5e-3;  % m
d.pred.strike_reach   = 'L';

% Angular spread of capture area
p.pred.strike_range   = pi/2;  % rad
d.pred.strike_range   = '';

% Receptive field of visual system (rad). Easter (1996) gives the functional 
% retinal field of 163 deg for 4 dpf. Though I give an additional 20 deg
% for saccades (based on vergenece angles of Patterson et al, 2013).
p.pred.vis_az     = 163/180*pi; % rad
d.pred.vis_az   = '';
%pred.vis_az     = (20)/180*pi; % rad

% Vergence angle: mean = 32 deg, max = 70 deg (value for larvae) (Patterson et al, 2013)
p.pred.verg_ang   = 32/180*pi; % rad
d.pred.verg_ang = '';

% Deg per photorecptor pair (Easter, 1996) for 4 dpf
p.pred.rtnl_den = 3.5 * 2.9235/180*pi; % rad
d.pred.rtnl_den = '';

% Sample rate of visual system
p.pred.vis_freq = 10; % 1/s
d.pred.vis_freq = '1/T';

% Threshold number of retinal cells for noticing prey
p.pred.vis_thresh = 0*1;
d.pred.vis_thresh = '';



%% Additional parameters

p.param.max_step = p.pred.sccd_prd/25;
d.param.max_step = 'T';


% capture distance threshold
p.param.d_capture = 1e-5;       % m
d.param.d_capture = 'L';
