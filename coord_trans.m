function [xRT,yRT] = coord_trans(type,theta,origin,x,y,verg_ang,vis_az,eye_side)
% Transforms points between coordinate systems 
%
% type      - String indicating the kind of transformation to perform
% theta     - Orientation of the FOR (1x1)
% origin    - Coordinates of origin of coordinate system (1x2)
% x         - vector of x-coordinates to transform (nx1)
% y         - vector of y-coordinates to transform (nx1)
% verg_ang  - vergence angle of the eyes in radians (1x1)
% vis_az    - Azimuth of the field of view in radians (1x1)
% eye_side  - String indicating which eye ('right' or 'left')


% Check coordinate dimensions
if (size(x,2)~=1) || (size(y,2)~=1)
    error('Coordinates must be given as a column vector');
end

if size(origin,2)~=2
    error('Origin must be given as a row vector');
end

switch type
    
    case 'global to body'
        
        % unit vector axes
        yaxis = [-sin(theta) cos(theta) 0]./norm([-sin(theta) cos(theta) 0]);
        xaxis = [cos(theta) sin(theta) 0]./norm([cos(theta) sin(theta) 0]);
        zaxis = [0 0 1];
        
        %Create rotation matrix (from local to inertial axes)
        R = [xaxis' yaxis' zaxis']';
        
        % Translate wrt origin
        x = x - origin(1);
        y = y - origin(2);
        
        % Package points in a matrix
        pts = [x y y.*0]';
        
        % Rotate points
        ptsT = [R * pts]';
        
        % Extract points
        xRT = ptsT(:,1);
        yRT = ptsT(:,2);        
    
        
   case 'body to global'
    
        % unit vector axes
        yaxis = [-sin(theta) cos(theta) 0]./norm([-sin(theta) cos(theta) 0]);
        xaxis = [cos(theta) sin(theta) 0]./norm([cos(theta) sin(theta) 0]);
        zaxis = [0 0 1];
        
        %Create rotation matrix (from inertial axes to local axes)
        R = [xaxis' yaxis' zaxis'];
        
        % Package points in a matrix
        pts = [x y y.*0]';
        
        % Rotate points
        ptsT = [R * pts]';
        
        % Extract points
        xRT = ptsT(:,1) + origin(1);
        yRT = ptsT(:,2) + origin(2);       
        

    case 'global to eye'
    % Note: this returns coordinates in the body FOR
    
        % Transform coordinates to the body FOR
        [x,y] = coord_trans('global to body',theta,origin,x,y);
        
        % psi - forward tilt angle of an eye relative to the body
        if strcmp(eye_side,'right')
            psi = -pi/2 + verg_ang/2;           
        elseif strcmp(eye_side,'left')
            psi = pi/2 - verg_ang/2;    
        else
            error('Did not recognize "eye_side" input')
        end
         
        % Transform coordinates to the eye FOR
        [x,y] = coord_trans('global to body',psi,[0 0],x,y);
        
        % Angular position of points
        pnt_ang = atan2(y,x);
        
        % Set up nan vectors
        xRT = nan(length(x),1);
        yRT = xRT;
        
        % Index of point in FOV
        idx = (pnt_ang >= -vis_az/2) & (pnt_ang <= vis_az/2);
        
        % Include only FOV points
        xRT(idx) = x(idx);
        yRT(idx) = y(idx);
        
        % Transform back into body coordinates
        [xRT,yRT] = coord_trans('body to global',psi,origin,xRT,yRT);
       
end







function R = prey_system(head,tail)

% Check dimensions
if size(head,1)~=1 || size(head,2)~=3 || size(tail,1)~=1 || size(tail,2)~=3 
    error('inputs have incorrect dimensions')
end

% Retrieve local x axis to determine coordinate system
xaxis(1,1) = tail(1) - head(1);
xaxis(1,2) = tail(2) - head(2);
xaxis(1,3) = tail(3) - head(3);

% Normalize to create a unit vector
xaxis = xaxis./norm(xaxis);

%Determine local y axis
%Short hand of cross product of inertial z axis and local x axis
yaxis = [-xaxis(2) xaxis(1) 0];

% Normalize to create a unit vector
yaxis = yaxis./norm(yaxis);

%Determine local z axis
zaxis = cross(xaxis,yaxis);

% Normalize to create a unit vector
zaxis = zaxis./norm(zaxis);

%Create rotation matrix (from inertial axes to local axes)
R = [xaxis; yaxis; zaxis];

% Take inverse
%R = inv(R);


function [pXg,pYg,pZg] = prey_local(head,R,pX,pY,pZ)
% Transforms polygon points from global to local FOR

tmp1 = global_to_local(head,R,[pX(1,:)' pY(1,:)' pZ(1,:)']);
tmp2 = global_to_local(head,R,[pX(2,:)' pY(2,:)' pZ(2,:)']);
tmp3 = global_to_local(head,R,[pX(3,:)' pY(3,:)' pZ(3,:)']);
tmp4 = global_to_local(head,R,[pX(4,:)' pY(4,:)' pZ(4,:)']);

pXg = [tmp1(:,1)'; tmp2(:,1)'; tmp3(:,1)'; tmp4(:,1)'];
pYg = [tmp1(:,2)'; tmp2(:,2)'; tmp3(:,2)'; tmp4(:,2)'];
pZg = [tmp1(:,3)'; tmp2(:,3)'; tmp3(:,3)'; tmp4(:,3)'];

function [pXg,pYg,pZg] = prey_global(head,R,pX,pY,pZ)
% Transforms polygon points from local to global FOR

tmp1 = local_to_global(head,R,[pX(1,:)' pY(1,:)' pZ(1,:)']);
tmp2 = local_to_global(head,R,[pX(2,:)' pY(2,:)' pZ(2,:)']);
tmp3 = local_to_global(head,R,[pX(3,:)' pY(3,:)' pZ(3,:)']);
tmp4 = local_to_global(head,R,[pX(4,:)' pY(4,:)' pZ(4,:)']);

pXg = [tmp1(:,1)'; tmp2(:,1)'; tmp3(:,1)'; tmp4(:,1)'];
pYg = [tmp1(:,2)'; tmp2(:,2)'; tmp3(:,2)'; tmp4(:,2)'];
pZg = [tmp1(:,3)'; tmp2(:,3)'; tmp3(:,3)'; tmp4(:,3)'];


function ptsT = global_to_local(head,R,pts)

% Translate
pts(:,1) = pts(:,1) - head(1);
pts(:,2) = pts(:,2) - head(2);
pts(:,3) = pts(:,3) - head(3);

% Rotate points
ptsT = [R * pts']';



function ptsT = local_to_global(head,R,pts)

% Rotate points
ptsT = [inv(R) * pts']';

% Translate global coordinates wrt head
ptsT(:,1) = ptsT(:,1) + head(1);
ptsT(:,2) = ptsT(:,2) + head(2);
ptsT(:,3) = ptsT(:,3) + head(3);


