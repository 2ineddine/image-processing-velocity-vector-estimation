function [dMAD, dMSSD, dH] = getDistance( img, ptsRef, ptsCtr )
%-------------------------------------------------------------%
% Calcul de 3 distances entre un contour de reference et un
% contour resultat
% Entrees:
%     - img: image sur laquelle les contours ont ete obtenus
%     - ptsRef: contour de reference (sous la forme de points [x y])
%     - ptsCtr: contour resultat (sous la forme de points [x y])
% Sortie:
%     - dMAD: distance absolue moyenne (MAD) entre les 2 contours
%     - dMSSD: mean sum of squared distance (MAD) entre les 2 contours
%     - dH: distance de Hausdorff
%-------------------------------------------------------------%
    % Interpolation des contours
    refI = interpCtr( ptsRef, 2 );
    ctrI = interpCtr( ptsCtr, 2 );
    % Index des points
    idxR = sub2ind( size(img), round( refI(:, 1) ), round( refI(:, 2) ) );
    idxC = sub2ind( size(img), round( ctrI(:, 1) ), round( ctrI(:, 2) ) );
    % Calcul des images binaires
    refImg = roipoly( img, refI(:, 2), refI(:, 1) );    refImg( idxR ) = 1;
    ctrImg = roipoly( img, ctrI(:, 2), ctrI(:, 1) );    ctrImg( idxC ) = 1;
    % Cartes de distances
    refCD = bwdist( refImg ) + bwdist( 1 - refImg ) - refImg;
    ctrCD = bwdist( ctrImg ) + bwdist( 1 - ctrImg ) - ctrImg;
    % Distances
    dMAD = ( mean( refCD( idxC ) ) + mean( ctrCD( idxR ) ) ) / 2;   % MAD
    dMSSD = sqrt( sum( refCD( idxC ).^2 ) / length(idxC) );         % MSSD
    dH = max( refCD( idxC ) );                                      % Hausdorff
    
    
    function ptsI = interpCtr( pts, scale )
        nbPts = size( pts, 1 );
        
        t = linspace( 0, 1, nbPts + 1 )';
        tI = linspace( 0, 1, scale * nbPts + 1 )';
        xI = spline( t, pts([1:end, 1], 1), tI );
        yI = spline( t, pts([1:end, 1], 2), tI );
        
        ptsI = [xI(1:end-1), yI(1:end-1)];