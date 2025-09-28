function ptsTrack = tracking( pts, u, v, sImg )
%---------------------------------------------%
% Suivi de points sachant leur mouvement
% Entrees:
%     - pts: les points a suivre sous la forme [x y]
%     - u: mouvement suivant x a t
%     - v: vitesse suivant y
%     - sImg: la taille de l'image
% Sortie:
%     - ptsTrack: les points a t+1
% Rq: les coordonnees des points ne sont pas 
%     entieres et il faut donc les arrondir 
%     avant de les convertir en indices
%---------------------------------------------%

    % On convertit les points en index
    pts = round( pts );
    idx = sub2ind( sImg, pts(:, 1), pts(:, 2) );
    % On applique le mouvement
    ptsTrack(:, 1) = pts(:, 1) + v( idx );
    ptsTrack(:, 2) = pts(:, 2) + u( idx );
    