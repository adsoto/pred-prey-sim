function [theta_target, senseTime] = see_fish(t, origin, theta, xFish, ...
                                              yFish, p, senseTime, theta_target)
% Determines whether the one fish sees the other
%
% t             - Current time (1x1)
% origin        - Coordinates of receiving fish (1x2)
% theta         - Orientation of receiving fish (1x1)
% xFish         - X-coordinates of stimulus (nx1)
% yFish         - Y-coordinates of stimulus (nx1)
% p             - Structure of parameters
% senseTime     - Time when stimulus first identified (1x1)
% theta_target  - Angle of stimulus, relative to receiver, in gobal FOR (1x1)


% Default output
fishSeen = 0;

% Prey coordinates in predator eye FORs
[xPreyR,yPreyR] = coord_trans('global to eye',theta, origin, xFish, ...
                     yFish,p.verg_ang,p.vis_az,'right');
[xPreyL,yPreyL] = coord_trans('global to eye',theta, origin, xFish, ...
                     yFish,p.verg_ang,p.vis_az,'left');

% Angular position of fish on retina                 
psiR = atan2(yPreyR,xPreyR);
psiL = atan2(yPreyL,xPreyL);

% If there's anything in the right eye . . .
if max(~isnan(psiR))  
    % At least report one photreceptor response
    nR = max([1 range(ceil(psiR/p.rtnl_den))]);  
else
    nR = 0;
end

% If there's anything in the left eye . . .
if max(~isnan(psiL))  
    % At least report one photreceptor response
    nL = max([1 range(ceil(psiL/p.rtnl_den))]);  
else
    nL = 0;
end

% Get sum of photoreceptors
nTot = nR + nL;

clear nR nL

% If something above threshold is in the field of view . . .
if nTot > p.vis_thresh   
    
    % If not already targeted (i.e. senseTime is a nan) . . .
    if isnan(senseTime)   
        
        % Roll the dice to see if fish is noticed
        if (randn(1)+nTot/10)>0 %TODO: Come up with a better random number generator
            senseTime    = t;
        end      
    end
       
    % If time since stimulus start exceeds sensory period . . .
    if ~isnan(senseTime) && (t-senseTime >=1/p.vis_freq)
        
        % Coordinates of stimulus in local FOR
        xCoords = [xPreyR(~isnan(psiR)); xPreyL(~isnan(psiL))];
        yCoords = [yPreyR(~isnan(psiR)); yPreyL(~isnan(psiL))];
        
        % Transform visible fish back into global FOR, with receiving fish
        % at origin
        fishCenter = [mean(xFish(:)) mean(yFish(:))];
        [xVis,yVis] = coord_trans('body to global',theta, fishCenter, ...
            xCoords, yCoords);
        
        % Define center of stimulus target wrt receiver
        theta_target = atan2(mean(yVis)-origin(2),mean(xVis)-origin(1));
        
        % Reset sensory clock
        senseTime = t;
        
    end
    
    % Note: will keep moving along same path if within sensory period
    
    
% If nothing is in the field of view . . .        
else
    
    % Set both time and angle to nans
    senseTime       = nan;
    theta_target    = nan;
    
end

% Visual check                 
if 0
    figure
    subplot(2,1,1)
    %plot(prey_x,prey_y,'b-',prey_x(1),prey_y(1),'bo',xPred,yPred,'ro-')
    subplot(2,1,2)
    plot(xPreyR,yPreyR,'b-',xPreyL,yPreyL,'b--')
end