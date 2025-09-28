function params = pts2Ellipse( pts )
%---------------------------------------------%
% Calcul des parametres d'une ellipse par moindres
% carres sachant les points du contour
% Entrees:
%     - pts: les points du contour
% Sortie:
%     - params: les 5 parametres d'une ellipse
%         (xC, yC, rX, rY, theta)
%---------------------------------------------%
    % Estimation de la forme quadratique de l'ellipse
    A = ellipseDirectFit( pts );
    
    [a, b, c, d, f, g] = deal( A(1), A(2), A(3), A(4), A(5), A(6) );
    b = b / 2;      d = d / 2;      f = f / 2;
    
    b2ac = b^2 - a*c;
    % Coordonnees du centre de l'ellipse
    xC = ( c*d - b*f ) / b2ac;
    yC = ( a*f - b*d ) / b2ac;
    % Grand et petit axe de l'ellipse
    num = sqrt( 2*( a*f^2 + c*d^2 + g*b^2 - 2*b*d*f - a*c*g ) );
    rX = num / sqrt( b2ac * ( sqrt( (a - c)^2 + 4*b^2 ) - (a + c) ) );
    rY = num / sqrt( b2ac * ( -sqrt( (a - c)^2 + 4*b^2 ) - (a + c) ) );
    % Orientation de l'ellipse
    if( b == 0 )
        if( a > c )
            theta = 0;
        else theta = pi / 2;
        end
    else
        if( a > c )
            theta = acot( (a - c ) / (2 * b) ) / 2;
        else
            theta = pi / 2 + acot( (a - c ) / (2 * b) ) / 2;
        end
    end
    params = [xC, yC, rX, rY, theta]';