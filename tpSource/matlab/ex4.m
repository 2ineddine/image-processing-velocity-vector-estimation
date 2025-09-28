clear variables
close all
clc

addpath src/suivi/filtreParticulaire/
addpath src/

dataPath = '../../data/';
seqNum = 1;
switch seqNum
    case 1
        seqName = 'Coke/';
        rect = [ 304; 164; 36; 73 ];
    case 2
        seqName = 'Woman/';
        rect = [ 214; 118; 20; 100 ];
    case 3
        seqName = 'ballonRouge/';
        rect = [ 153; 67; 33; 37 ];
    case 4
        sqeName = 'Beanbags/';
        rect = [ 154; 148; 35; 37 ];
end
seq = readSeq( [dataPath, seqName], 0 );

% Parametres
sSeq = size( seq );
isColor = length( sSeq ) > 3;
sigma = 25;     % sigma de propagation
nbPart = 100;	% nombre de particules
lambda = 100;   % facteur de vraisemblance
nbBin = 50;    % nombre de bins des histogrammes
alpha = 0.1;    % facteur de reechantillonnage
tMax = 100;     % nombre de frames
nbDisplay = 6;  % nombre d'affichage
dT = round( tMax / (nbDisplay - 1) );

% Initialisation
figure(1);
if( isColor )
    img = squeeze( seq(:,:,:,1) );
    imagesc( img );
else
    img = seq(:,:,1);
    imagesc( img ); colormap gray;
end
axis image; axis off;

% rect = round( getrect );
l = ceil( ( rect(3) - 1 ) / 2 );        cX = rect(1) + l;
w = ceil( ( rect(4) - 1 ) / 2 );        cY = rect(2) + w;
% Calcul de l'histogramme de reference
subI = img( (cY - w):(cY + w), (cX - l):(cX + l), : );
hRef = getHisto( subI, nbBin );
% Creation des particules
xK = repmat( [cX; cY], [1, nbPart] );       omegaK = ones(1, nbPart ) / nbPart;

hold on;
    plot( xK(1, :), xK(2, :), 'og', 'linewidth', 2 );
    rectangle( 'Position', [ cX - l, cY - w, 2*l, 2*w ], 'EdgeColor', 'b', 'linewidth', 2 );
hold off;
% Suivi
for t = 2:1:tMax
    if( isColor )
        img = squeeze( seq(:,:,:,t) );
    else
        img = seq(:,:,t);
    end
    % Evolution des particules
    [xK, omegaK] = particleFiltering( img, xK, omegaK, nbPart, hRef, l, w, sigma, lambda, alpha );
    % Estimation de la position courante de l'objet
    xEst = round( sum( omegaK .* xK(1, :) ) );
    yEst = round( sum( omegaK .* xK(2, :) ) );

	imagesc( img ); axis image; axis off;
	hold on;
		plot( xK(1, :), xK(2, :), 'xr', 'linewidth', 2 );
		rectangle( 'Position', [ xEst - l, yEst - w, 2*l, 2*w ], 'EdgeColor', 'b', 'linewidth', 2 );
	hold off;
	title( [ 'Frame ', num2str( t ) ] );
	drawnow
end
