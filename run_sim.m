function run_sim
% Runs single simulation and analyzes results


% Default parameter values
[p,d] = default_params;

p.param.sL = 1;
p.param.sT = 1;

p.param.t_span = [0 50];

%% Run simulation

R = simple_model(p,d);

R = reconstruct(R, p, d);


%% Report result


% Display whether or not prey escaped
if isempty(R.tEnd)
    disp('prey successfully escaped')
else
    disp(['the prey was captured at time = ' num2str(R.tEnd)])
end


%% Plot results

% Plot orientation angles
% vis_results('Turning data',R)


vis_results('Trajectories',R)


%% Animate simulation

% figure('DoubleBuffer','on')
% vis_results('Animate',R)
% TODO: Fix the animation code




