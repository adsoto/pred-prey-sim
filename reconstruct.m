function R = reconstruct(R, p, d, type)
% Reconstructs events in simulation

% Defaults
if nargin < 4
    type = 'full';
end

% Major field names
fName{1} = 'prey';
fName{2} = 'pred';
%fName{3} = 'param';

% Store input parameters
R.p     = p;
R.d     = d;

% Create 's' structure
s = [];

% Step thru time
for i = 1:length(R.t)
    
    % BEHAVIORAL CHANGES (for current time)
    s = give_behavior(p.param.sim_type, p, s, R.t(i), R.X(i,:));
    
    % GET ALL VALUES IN "s" STRCUTURE
    % Step thru each major field ('pred' and 'prey')
    for j = 1:2
        
        % Get sub-field names
        eval(['names = fieldnames(s.' fName{j} ');']);
        
        % Step thru sub-fields
        for k = 1:length(names)
            
            % Get parameter value for current field
            eval(['valIn = s.' fName{j} '.' names{k} ';'])
            
            % Pass value into field
            if ~(strcmp(names{k}(2:end),'BodL') && (i>1))
                if length(valIn)==1
                    eval(['R.' fName{j} '.' names{k} '(i,1) = valIn;' ])
                elseif size(valIn,2)==1
                    eval(['R.' fName{j} '.' names{k} '(:,i) = valIn;' ])
                elseif size(valIn,1)==1
                    eval(['R.' fName{j} '.' names{k} '(i,:) = valIn;' ])
                else
                    error('Cannot deal with 2D matricies')
                end
            end
        end
    end
    
end


%  % Store coordinates for suction
%     R.pred.xSuc(:,i)    = s.pred.xSuc;
%     R.pred.ySuc(:,i)    = s.pred.ySuc;
%     R.pred.rSuc(:,i)    = s.pred.rSuc;
%     
%     % Store rates of change
%     R.pred.omega(i,1)   = s.pred.omega;
%     R.prey.omega(i,1)   = s.prey.omega;
%     R.pred.spd(i,1)     = s.pred.spd;
%     R.prey.spd(i,1)     = s.prey.spd;
%     
%     % Predator behavioral states
%     R.pred.strike(i,1)  = ~isnan(s.pred.strikeTime);
%     R.pred.seePrey(i,1) = ~isnan(s.pred.inFieldTime);
%     R.pred.onSccd(i,1)  = s.pred.onSccd;
%     R.pred.thetaTarget(i,1) = s.pred.thetaTarget;
%     
%     % Prey behavioral states
%     R.prey.escape(i,1)         = s.prey.escapeOn;
%     R.prey.onSccd(i,1)         = s.prey.onSccd;
%     R.prey.captured(i,1)       = s.captured;


