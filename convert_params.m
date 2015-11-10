function p = convert_params(pIn,d)
% Normalizes parameter values, according to scaling constants and the
% dimensions of each parameter.

% Major field names
fName{1} = 'prey';
fName{2} = 'pred';
fName{3} = 'param';

% Scaling constants
sL = pIn.param.sL;
sT = pIn.param.sT;

% Step thru each major field
for i = 1:3
    
    % Get sub-field names
    eval(['names = fieldnames(pIn.' fName{i} ');']);
    
    % Step thru sub-fields
    for j = 1:length(names)
        
        % Get parameter value for current field
        eval(['valIn = pIn.' fName{i} '.' names{j} ';'])
        
        % Get dimensions of current field
        eval(['dims = d.' fName{i} '.' names{j} ';'])
        
        % Perform conversion for requested dimensions
        if strcmp(dims,'L')
            valIn = valIn  / sL;
            
        elseif strcmp(dims,'T')
            valIn = valIn  / sT;
            
        elseif strcmp(dims,'1/T')
            valIn = valIn  * sT;
            
        elseif strcmp(dims,'L/T')
            valIn = valIn  /sL * sT;
            
        elseif strcmp(dims,'')
            % Do nothing
            
        else
            error('Dimensions not recognized');
        end
        
        % Pass value into field
        eval(['p.' fName{i} '.' names{j} ' = valIn;' ])
        
    end 
end