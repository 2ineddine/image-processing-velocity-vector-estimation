function flow2Hsv( varargin )
% Usage: flow2Hsv( [x], [y], u, v, [maxspeed] )
% Given a gridded velocity field, flow2Hsv plots the velocity with 
% color, representing direction with hue and speed with saturation.
% 
% Inputs:
%   - x, y (optional): coordinates corresponding to flow position (1D array)
% 	- u, v: motion in x and y (2D matrices),
% 	- maxspeed (optional): the speed for full saturation
%
% Example:
% 	x = -2:.2:2; y = -1:.15:1;
% 	[xx, yy] = meshgrid( x, y );
%	z = xx .* exp( -xx.^2 - yy.^2 ); 
%	[px, py] = gradient( z, .2, .15 );
%	flow2Hsv( x, y, px, py ); hold on
%	quiver( xx, yy, px, py, 'k' )

    %-- Prompt for syntax if no inputs given -=-
if nargin<1
    error( [ 'Usage: ', mfilename, ...
        '( [x], [y], u, v, [maxspeed] )' ] );
end

    %-- Parse input arguments -=-
if isvector(varargin{1}) % expect hsvel(x,y,u,v,...)
    if( ~isvector(varargin{2}) )
        error('Sorry, x and y must both be vectors.')
    end
    if numel(varargin) < 5
        argin = [ varargin cell(1, 5 - numel(varargin) ) ];
    else
        argin = varargin;
    end
    x = argin{1};
    y = argin{2};
    u = argin{3};
    v = argin{4};
    maxspeed = argin{5};
else % expect hsvel(u,v,...)
    if( numel( varargin ) < 3 )
        argin = [ varargin cell(1, 3 - numel(varargin)) ];
    else
        argin = varargin;
    end
    u = argin{1};
    v = argin{2};
    maxspeed = argin{3};
    
    x = 1:size(u, 2); % default coordinates, as image.m would use
    y = 1:size(u, 1);
end
if( any(size(u) ~= size(v)) )
    error('Sorry, u and v must be the same size.')
end
if( numel(x) ~= size(u, 2) || numel(y) ~= size(u, 1) || ...
        numel(x) ~= size(v, 2) || numel(y) ~= size(v, 1) )
    error('Sorry, u and v must have the same size as meshgrid(x, y).')
end

%% Velocity field
    %-- Calculate colors
velmag = sqrt( u.^2 + v.^2 );
if( ~exist('maxspeed','var') || isempty(maxspeed) )     % use full range if no limit provided
    maxspeed = max( velmag(:) );
elseif numel(maxspeed) > 1
    error('Sorry, maxspeed must be a scalar.')
end
velmag = velmag / maxspeed;
velmag( velmag > 1 ) = 1;
c = nan( [size(u) 3] );
c(:, :, 1) = (atan2(v, u) + pi) / (2 * pi);
c(:, :, 2) = 1;
c(:, :, 3) = velmag;
c = hsv2rgb(c);
    %-- Now plot
image( x, y, c );
