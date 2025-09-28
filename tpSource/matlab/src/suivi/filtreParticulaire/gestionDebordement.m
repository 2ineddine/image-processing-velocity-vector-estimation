function [xG, yG] = gestionDebordement( x, y, sImg )
% ------------------------------------------------- %
% Gere les particules en dehors de l'image en les 
% remettant sur le bord le plus proche.
%
% Inputs:
%     - x: abscisses des particules
%     - y: ordonnees des particules
%     - sImg: dimensions (en x et en y) de l'image
% Outputs:
%     - xG: abscisses des particules apres gestion 
%           des debordements
%     - yG: ordonnees des particules apres gestion 
%           des debordements
% ------------------------------------------------- %

    xG = max( min( x, sImg(1) ), 1 );
    yG = max( min( y, sImg(2) ), 1 );