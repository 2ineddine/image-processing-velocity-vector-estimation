function d = dBhattacharrya( hRef, hImg )
%---------------------------------------%
% Calcul de la distance de Bhattacharyya
% entre 2 histogrammes
% Entrees:
%     - hRef: histogramme de reference
%     - hImg: histogramme cible
% Sortie:
%     - d: distance de Bhattacharrya
%---------------------------------------%
    d = 0;
    for c = 1:1:size( hRef, 2 )     % Pour chaque plan couleur
        d = d - log( sum( sqrt( hRef(:) .* hImg(:) ) ) );
    end