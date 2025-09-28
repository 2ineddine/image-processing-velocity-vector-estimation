function pts = ellipse2Pts( params, nbPts )
%---------------------------------------------%
% Calcul des points de l'ellipse
% Entrees:
%     - params: les 5 parametres d'une ellipse
%         (xC, yC, rX, rY, theta)
%     - nbPts: nombre de points du contour
% Sortie:
%     - pts: points du contour sous la forme [x y]
%---------------------------------------------%
    dt = 2 * pi / (nbPts - 1);
    t = (-pi:dt:pi)';
    
    xE = params(1) + params(3) * cos( t + params(5) );
    yE = params(2) + params(4) * sin( t + params(5) );
    pts = [xE, yE];