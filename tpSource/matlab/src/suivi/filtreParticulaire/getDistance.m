function d = getDistance( hRef, hImg )
    %-- Distance de Bhattacaryya
    d = -log( sum( sqrt( hRef .* hImg ) ) );