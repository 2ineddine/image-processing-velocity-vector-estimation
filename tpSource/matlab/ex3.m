clear variables;
% close all;
% clc;

addpath( genpath( 'src' ) )

%% Load data
load( '../../data/SAx/SAx01.mat' );
% load( 'data/SAx/SAx02.mat' );
pts = refEndo;
% pts = refEpi;
sSeq = size( seq );

%% Parametres
nbPts = 20;     % Nombre de points de l'ellipse
    %-- Kalman
s2v = 5e3;      % Bruit sur l'etat / le modele
s2n = 1e0;      % Bruit sur l'observation

%% Initialisation
tmp = pts( pts(:, 3) == 1, 1:2 );           % Reference sur la 1ere frame
uT = u( :, :, 1 );      vT = v( :, :, 1 );  % Vitesse estimee entre les 2 premieres frames
    %-- Tracking
ptsT = zeros( [ size(tmp, 1), 2, sSeq( 3 ) ] );
ptsT(:, :, 1) = tmp;
ptsT(:, :, 2) = tracking( ptsT(:, :, 1), uT, vT, sSeq(1:2) );   % On applique le mouvement estimee a la reference
    %-- Kalman
ptsK = zeros( [ nbPts, 2, sSeq( 3 ) ] );
    % t = 1
xE1 = pts2Ellipse( tmp );                   % On estime l'ellipse representant au mieux la reference
ptsK(:, :, 1) = ellipse2Pts( xE1, nbPts );  % On la discretise en nbPts
    % t = 2
ptsKT = tracking( ptsK(:, :, 1), uT, vT, sSeq(1:2) );   % On applique le mouvement estimee a l'ellipse
xE2 = pts2Ellipse( ptsKT );                 % On estime l'ellipse representant au mieux le contour suivi
ptsK(:, :, 2) = ellipse2Pts( xE2, nbPts );  % On la discretise en nbPts

%% Definition des differentes variables pour Kalman
F = [ eye(5), dT * eye(5); zeros(5), eye(5) ];
G = [ eye(5), zeros(5) ];
W = [ zeros(5), zeros(5); zeros(5), eye(5) ] * s2v;
V = eye(5) * s2n;
I = eye( 10 );
xE = [ xE2; (xE2 - xE1) / dT ];
Px = [ V, V / dT; V / dT, 2*V / dT^2 ];

%% Tracking
dMAD = zeros( sSeq(3), 2 );     dMSSD = zeros( sSeq(3), 2 );        dH = zeros( sSeq(3), 2 );
figure(1); colormap gray;
for t = 3:1:sSeq(3)
    uT = u( :, :, t-1 );      vT = v( :, :, t-1 );
    %-- Tracking
    ptsT(:, :, t) = tracking( ptsT(:, :, t-1), uT, vT, sSeq(1:2) );
    %-- Kalman
        % Calcul de l'observation
        ptsKT = tracking( ptsK(:, :, t-1), uT, vT, sSeq(1:2) );
        y = pts2Ellipse( ptsKT );
        % Prediction
        xE = F * xE;
        Px = F * Px * F' + W;
        % Observation
        yEst = G * xE;
        yI = y - yEst;
        Py = G * Px * G' + V;
        % Mise a jour
        K = Px * G' / Py;  % Gain de Kalman
        Kp = I - K * G;
        xE = xE + K * yI;	% Correction de l'etat
        Px =  Kp * Px * Kp' + K * V * K';     % Precision
        % Discretisation de l'ellipse pour avoir le nouveau contour
        ptsK(:, :, t) = ellipse2Pts( xE(1:5), nbPts );
    %-- Distance avec la reference
    ptsR = pts( pts(:, 3) == t, 1:2 );    
%     [dMAD(t, 1), dMSSD(t, 1), dH(t, 1)] = getDistance( seq(:, :, t), ptsR, ptsT(:, :, t ) );
%     [dMAD(t, 2), dMSSD(t, 2), dH(t, 2)] = getDistance( seq(:, :, t), ptsR, ptsK(:, :, t ) );
    %-- Affichage
    imagesc( seq(:, :, t) ); axis image; axis off;
    hold on;
        plot( ptsR(:, 2), ptsR(:, 1), 'g', 'linewidth', 2 );
        plot( ptsT(:, 2, t), ptsT(:, 1, t), '-.r', 'linewidth', 2 );
        plot( ptsK(:, 2, t), ptsK(:, 1, t), '-.c', 'linewidth', 2 );
    hold off;
    legend( 'Reference', 'Tracking', 'Kalman' );
    title( [ num2str(t), ' / ', num2str( sSeq(3) ) ] );
    pause( 0.01 );
end
% disp( [ 'MAD (en px): ', num2str( mean( dMAD(3:end, :) ) ) ] );
% disp( [ 'MSSD (en px): ', num2str( mean( dMSSD(3:end, :) ) ) ] );
% disp( [ 'Distance de Hausdorff (en px): ', num2str( mean( dH(3:end, :) ) ) ] );
