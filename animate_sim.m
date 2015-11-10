function animate_sim(R,play_dur,fps)
% Animates the results of a predtaor-prey simulation over a defined
% duration. play_dur is the duration of animation (s). fps is the frame
% rate of the rendering.

% Set default values
if nargin < 3
    fps = 10;
    if nargin < 2
        play_dur = 5;
    end
end

% Get limits
xlims(1) = min([R.xPred; R.xPrey]).*.8;
xlims(2) = max([R.xPred; R.xPrey]).*1.2;
ylims(1) = min([R.yPred; R.yPrey]).*.8;
ylims(2) = max([R.yPred; R.yPrey]).*1.2;

% Time vector for rendering values
t_render = linspace(0,play_dur,fps*play_dur);

% Normalize time of simulation results wrt animation duration
t_norm = R.t/max(R.t)*play_dur;

% Create figure window
figure('DoubleBuffer','on')

% Start timer
clock_start = tic;

% Containers for data
xPred = []; yPred = []; xPrey = []; yPrey = [];

% Look through time
for i = 1:length(t_render)
    
    % Interpolate results for even timing
    xPred = [xPred; interp1(t_norm,R.xPred,t_render(i))];
    yPred = [yPred; interp1(t_norm,R.yPred,t_render(i))];
    xPrey = [xPrey; interp1(t_norm,R.xPrey,t_render(i))];
    yPrey = [yPrey; interp1(t_norm,R.yPrey,t_render(i))];
    
    % Render traces
    h = plot(xPred,yPred,'-',xPred(end),yPred(end),'o',...
             xPrey,yPrey,'-',xPrey(end),yPrey(end),'o');
         
    % Set axis     
    axis square
    xlim(xlims)
    ylim(ylims)
    
    % Get color palatte
    clrs = get(gca,'ColorOrder');
    
    % Set colors
    set(h(1:2),'Color',clrs(2,:))
    set(h(3:4),'Color',clrs(1,:))
    set(h(2),'MarkerFaceColor',clrs(2,:))
    set(h(4),'MarkerFaceColor',clrs(1,:))
    
    % Get elapsed time
    telaspsed = toc(clock_start);
    
    % Pause to adjust pacing
    if t_render(i)>telaspsed
        pause(t_render(i)-telaspsed);
    else
        pause(1e-6)
    end
          
end

telaspsed = toc(clock_start);

% Check duration
if telaspsed > 1.2*play_dur
    warning(['Could not render animation fast enough to play at' ...
             ' requested duration']);
end