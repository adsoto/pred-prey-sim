function vis_results(graph_type,R)
% General function for plotting the results of an individual simulation
%
% R             - Structure that stores results from simulations
% graph_type    - String that designates the type of graph

% Create figure window
figure('DoubleBuffer','on')

% Get color palette
clrs = get(gca,'ColorOrder');

% Check for 'reconstruct' data
if ~isfield(R,'pred')
    error('you need to apply "reconstruct.m" to the R structure');
end
    

%% Give requested visualization

switch graph_type

case 'Angle and speed'
% Plot of body orientation and rate of change in orientaion
    
    subplot(2,1,1)

    % Figure out y-axis limits
    h = plot(R.t,unwrap(R.thetaPred).*180/pi,'-',...
        R.t,unwrap(R.thetaPrey).*180/pi,'-');  
    yL = ylim; 
    delete(h)
    
    % Index for items plotted
    idx = 0;

    % If any strikes . . .
    if sum(~isnan(R.pred.strikeTime)) > 0
        
        % Advance index
        idx = idx + 1;
        
        % Plot strikes
        h(idx) = plot_events(R.t,~isnan(R.pred.strikeTime),yL,clrs(2,:),0.5);
        hold on
        
        % Legend text
        txt{idx} = 'Strike';

    end
    
    % If any escapes . . .
    if sum(R.prey.escapeOn) > 0
        
        % Advance index
        idx = idx + 1;
        
        % Plot escapes
        h(idx) = plot_events(R.t,R.prey.escapeOn,yL,clrs(1,:),0.3);
        hold on
        
        % Legend text
        txt{idx} = 'Escape';      
    end
    
    % Plot body orientation
    h((idx+1):(idx+2)) = plot(R.t,unwrap(R.thetaPred).*180/pi,'-',...
                  R.t,unwrap(R.thetaPrey).*180/pi,'-');
    txt{idx+1} = 'Predator';
    txt{idx+2} = 'Prey';
    hold off
    
    % Make pretty
    set(h(idx+2),'Color',clrs(1,:))
    set(h(idx+1),'Color',clrs(2,:));
    xlabel('Time (s)')
    ylabel('Orientation (deg)')
    legend(h,txt,'Location','NorthWest')
    if sum(R.prey.captured)
        title('Capture');
    else
        title('Escape')
    end
    
    hold off
    clear h
    
    % Plot rates of change in orientation
    subplot(2,1,2)

    % Figure out y-axis limits
    prey_spd = sqrt(diff(R.xPrey).^2 + diff(R.yPrey).^2)./diff(R.t);
    h = plot(R.t,R.pred.spd.*100,'-',R.t,R.prey.spd.*100,'-');
    yL = ylim; 
    delete(h)    
    
   % Index for items plotted
    idx = 0;

    % If any strikes . . .
    if sum(~isnan(R.pred.strikeTime)) > 0
        
        % Advance index
        idx = idx + 1;
        
        % Plot strikes
        h(idx) = plot_events(R.t,~isnan(R.pred.strikeTime),yL,clrs(2,:),0.5);
        hold on
    end
    
    % If any escapes . . .
    if sum(R.prey.escapeOn) > 0
        
        % Advance index
        idx = idx + 1;
        
        % Plot escapes
        h(idx) = plot_events(R.t,R.prey.escapeOn,yL,clrs(1,:),0.3);
        hold on     
    end
    
    % Plot omega
    h((idx+1):(idx+2)) = plot(R.t,R.pred.spd.*100,'-',R.t,R.prey.spd.*100,'-');
    
    set(h(idx+2),'Color',clrs(1,:))
    set(h(idx+1),'Color',clrs(2,:));
    xlabel('Time (s)')
    ylabel('Speed (cm/s)')
    
    hold off
    
    
case 'Trajectories'
% Plot trajectories 

    % Number of points for the wall 
    num_pts = 200;
    
    % Radial coordinates for the wall
    phi = linspace(0,2*pi,500);

    % Extract wall radius 
    r = R.p.param.tank_radius;

    % Get limits
    xlims(1) = -r * 1.1;
    xlims(2) =  r * 1.1;
    ylims(1) = -r * 1.1;
    ylims(2) =  r * 1.1;

    % Time vector for rendering values
    t_render = linspace(0,R.t(end),num_pts);

    % Interpolate results for even timing
    xPred = interp1(R.t,R.xPred,t_render);
    yPred = interp1(R.t,R.yPred,t_render);
    xPrey = interp1(R.t,R.xPrey,t_render);
    yPrey = interp1(R.t,R.yPrey,t_render);

    % Render traces
    h = plot(R.xPred,R.yPred,'-',...
             xPred,yPred,'o',...           
             R.xPrey,R.yPrey,'-',...
             xPrey,yPrey,'o',...
             R.xPred(end),R.yPred(end),'o',...
             R.xPrey(end),R.yPrey(end),'o');

    hold on
    h2 = plot(r.*cos(phi),r.*sin(phi),'-k');
    hold off
    
    set(h(2),'MarkerSize',2)
    set(h(4),'MarkerSize',2)
    set(h(5),'MarkerSize',4)
    set(h(6),'MarkerSize',4)

    % Set axis
    axis square
    xlim(xlims)
    ylim(ylims)

    % Set colors
    set(h(1:2),'Color',clrs(2,:))
    set(h(3:4),'Color',clrs(1,:))
    set(h(2),'MarkerFaceColor',clrs(2,:))
    set(h(4),'MarkerFaceColor',clrs(1,:))
    set(h(5),'MarkerFaceColor',clrs(2,:))
    set(h(6),'MarkerFaceColor',clrs(1,:))
    set(h(5),'MarkerEdgeColor',clrs(2,:))
    set(h(6),'MarkerEdgeColor',clrs(1,:))

    % Removed axes
    set(gca,'Box','off')
    set(gca,'XColor','w')
    set(gca,'YColor','w')

    
case 'Animate'     
% Animate simulation

    % Duration for playing video (s)
    play_dur = 7;
    
    % Frame rate (Hz) 
    fps = 15;
    
     % Number of points for the wall 
    num_pts = 200;
    
    % Number of points for the body
    num_bod_pts = 200;
    
    % Radial coordinates for the wall
    phi = linspace(0,2*pi,500);

    % Extract wall radius 
    r = R.p.param.tank_radius/20;
    
    % Get limits
    xlims(1) = -r * 1.1;
    xlims(2) =  r * 1.1;
    ylims(1) = -r * 1.1;
    ylims(2) =  r * 1.1;
    
    % Number of time instants to simulate
    num_t = fps*play_dur;
    
    % Time vector for rendering values
    t_render = linspace(R.t(1),R.t(end),num_t);
    
    % Reconstruct the behavior of predators and prey
    %[pred,prey] = reconstruct(R);  
    
    % Normalized time vector
    t_norm = R.t/max(R.t)*play_dur;
        
    % Time vector for rendering values
    t_render = linspace(0,play_dur,fps*play_dur);
     
    % Interpolate predator results for even timing
    xPred       = interp1(t_norm,R.xPred,t_render);
    yPred       = interp1(t_norm,R.yPred,t_render);
    thetaPred   = interp1(t_norm,R.thetaPred,t_render);
    
    % Strike data
    for i = 1:size(R.pred.xSuc,1)
        xSuc(i,:) = interp1(t_norm',R.pred.xSuc(i,:),t_render);
        ySuc(i,:) = interp1(t_norm',R.pred.ySuc(i,:),t_render);
    end
    
    % Interpolate prey results for even timing
    xPrey       = interp1(t_norm,R.xPrey,t_render);
    yPrey       = interp1(t_norm,R.yPrey,t_render);
    thetaPrey   = interp1(t_norm,R.thetaPrey,t_render);
    
    % Find body position of both fish
    %s = [];  

    % Start timer
    clock_start = tic;
      
    % Loop through time
    for i = 1:length(t_render)
          
        % Draw walls
        h2 = plot(r.*cos(phi),r.*sin(phi),'-k');
        hold on       

        % Transform body points of predator into global FOR
        [xBodPredG, yBodPredG] = coord_trans('body to global', ...
                        thetaPred(i), [xPred(i) yPred(i)], R.pred.xBodL, R.pred.yBodL);
        
        % Transform body points of prey into global FOR
        [xBodPreyG, yBodPreyG] = coord_trans('body to global', ...
            thetaPrey(i), [xPrey(i) yPrey(i)], R.prey.xBodL, R.prey.yBodL);
        
        % Render traces
        h = plot(xPred(1:i),yPred(1:i),'-',xPrey(1:i),yPrey(1:i),'-');
       
        % Render predator
        hB(1) = fill(xBodPredG,yBodPredG,clrs(2,:));
        set(hB(1),'EdgeColor','none')

        % Render prey
        hB(2) = fill(xBodPreyG,yBodPreyG,clrs(1,:));
        set(hB(2),'EdgeColor','none')
              
        % Render suction field
        bS = plot(xSuc(:,i), ySuc(:,i),'k');
        
        % Set axis
        axis square
        xlim(xlims)
        ylim(ylims)
        
        % Get color palatte
        clrs = get(gca,'ColorOrder');
        
        % Set colors
        set(h(1),'Color',clrs(2,:))
        set(h(2),'Color',clrs(1,:))

        % Removed axes
        set(gca,'Box','off')
        set(gca,'XColor','w')
        set(gca,'YColor','w')
        
        % Title
        %title(['Time = ' num2str(t_render(i)) ' s'])
        
        % Get elapsed time
        telaspsed = toc(clock_start);
        
%         % Pause to adjust pacing
%         if t_render(i)>telaspsed
%             pause(t_render(i)-telaspsed);
%         else
%             pause(1e-6)
%         end
        
        pause(1e-6)
        
        hold off
    end
    
    telaspsed = toc(clock_start);
    
    % Check duration
    if telaspsed > 1.2*play_dur
        warning(['Could not render animation fast enough to play at' ...
            ' requested duration']);
    end
     
    
end


function h = plot_events(t, bEvent, yL, clr, aLevel)

% Default handle
h = 0;

% Indicies for onset and offset
tOn     = t(diff(bEvent)==1);
tOff    = t(diff(bEvent)==-1);

% Tack on ending, if necessary
if length(tOff)<length(tOn)
    tOff(end+1) = t(end);
end

% Loop thru events
for i = 1:min([length(tOn) length(tOff)])
    h = fill([tOn(i) tOff(i) tOff(i) tOn(i)], [yL(1) yL(1) yL(2) yL(2)],clr);
    hold on
    alpha(h,aLevel)
    set(h,'EdgeColor','none')
end

hold off



function [pred, prey] = reconstruct_old(R,t)
% Recontructs the behavior of fish during a simulation for requested time
% vector

% Intitialize state variables
s = give_behavior('Initialize', R.p);

% If time vector given . . .
if nargin > 1
    % Interpolate each sim result variable
    for i = 1:6
        X(:,i) = interp1(R.t,R.X(:,i),t);
    end

% Otherwise, use simulation time steps
else
    t = R.t;
    X = R.X;
end

% Step thru time
for i = 1:length(t)

    % Find body position of both fish
    s = give_behavior('Body positions', R.p, s, t(i), X(i,:));
    
    % Set prey behavior
    s = give_behavior('Prey', R.p, s, t(i), X(i,:));
    
    % Set predator behavior
    s = give_behavior('Predator', R.p, s, t(i), X(i,:));
    
    % Determine whether prey is captured
    s = give_behavior('Strike', R.p, s, t(i), X(i,:));
    
    %if ~isnan(s.pred.strikeTime)
        
    %end
    
    % Store prey body values
    prey.xBodG(:,i) = s.prey.xBodG;
    prey.yBodG(:,i) = s.prey.yBodG;
    
    % Store prey position
    prey.x(i,1)       = X(i,1);
    prey.y(i,1)       = X(i,2);
    prey.theta(i,1)   = X(i,3);
    
    % Store predator body position
    pred.xBodG(:,i) = s.pred.xBodG;
    pred.yBodG(:,i) = s.pred.yBodG;
    
    % Store predator position
    pred.x(i,1)       = X(i,4);
    pred.y(i,1)       = X(i,5);
    pred.theta(i,1)   = X(i,6);
    
    % Store predator suction
    pred.xSuc(:,i)    = s.pred.xSuc;
    pred.ySuc(:,i)    = s.pred.ySuc;
end







