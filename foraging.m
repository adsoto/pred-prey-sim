function [omega, t_sccd, dirSccd, onSccd] = ...
               foraging(param, t_sccd, t, dirSccd, onSccd)
% Describes instantaneous routine foraging behavior 
%
% x       - x-position of body (nx1)
% y       - y-position of body (nx1)
% theta   - Body orientation of predator (or prey) (1x1)
% param   - Structure of predator (or prey) parameters
% t_sccd  - Time of start of last saccade (i.e. turn) (1x1)
% t       - Current time (1x1, can be vector for testing)
% dirSccd - Saccade direction (1 or -1)
% onSccd  - Currently executing a saccade (logical)
% player  - Either 'predator' or 'prey'
% 
% omega  - rate of body rotation

%gain = 20;

% % Max distance of body from origin
%body_dist = max(hypot(xBod, yBod));

% Tank radius
%tank_rad = max(hypot(xTank, yTank));

% % If bumped into to a wall . . .
% if body_dist >= tank_rad
%     
%     % Index of points that exceed the boundary
%     idx = hypot(xBod,yBod) > tank_rad;
%     
%     % Body points outside
%     xOut    = xBod(idx);
%     yOut    = yBod(idx);
%     
%     % Find distances for all head points to all tank points
%     dist = hypot(xOut,yOut);
%     
%     % Find furthest distance
%     iMax = find(dist==max(dist(:)),1,'first');
%     
%     % Angle of that furthest point
%     ang_max = atan2(yOut(iMax),xOut(iMax));
%     
%     % Direction of turn
%     turn_dir = (theta - ang_max) ./ norm(theta - ang_max);
%     
%     % Tangent along wall
%     tan_ang = ang_max + turn_dir*(pi/2 + 15/180*pi);
%     
%     % Normalized deviation from tangent
%     dev_ang = (tan_ang - theta) / pi;
%     
%     % Make omega proportional to deviation
%     omega = dev_ang * pred.wall_omega;
%     
%     % Set saccade start to current time
%     t_sccd = t;
%     
%     % Turn off routine saccades
%     onSccd = 0;
%    
    
% If currently executing a saccade  . . .
if onSccd
      
    % Calculated time within the saccade
    tc = t - t_sccd;
    
    % If this time has exceeded saccade period . . .
    if tc > param.sccd_prd
        
        % Turn off logical
        onSccd = 0;
        
        % Zero out omega
        omega = 0;  
        
        % Determine next saccade direction 
        dirSccd = rand(1);dirSccd = (dirSccd-.5)./abs(dirSccd-.5);
        
    % Otherwise, continue with saccade function . . .
    else    
        
        % Define current rate of turn
        omega = saccade_func(tc,param.sccd_omega,param.sccd_prd,dirSccd);   
        
    end
       
% If not already executing a saccade . . .
else
    
    % Next saccade time (useful for some code below)
    t_next = t_sccd + param.sccd_intvl;

    % If current time exceeds the next scheduled saccade . . .
    if t >= t_next
        
        % Set new saccade start time
        t_sccd = t_next;
        
        % Turn on logical 
        onSccd = 1;
        
        % Define current rate of turn
        omega = saccade_func(t-t_next,param.sccd_omega,param.sccd_prd,dirSccd); 
    
    % Otherwise, we are between saccades . . .
    else            
        % . . . so zero rate of angular change
        omega = 0;         
    end
end




    
function omega = saccade_func(t, amp, dur, dirSccd)
% Curve describing the turning rate

omega = amp.*(0.5.*(sin(2*pi*t./dur-pi/2)+1));

% Set direction
omega = dirSccd .* omega;

