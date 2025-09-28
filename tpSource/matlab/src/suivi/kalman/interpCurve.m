function ptsI = interpCurve( pts, nbPts )
    x = pts(:, 1);      y = pts(:, 2);

    t = [ 0; cumsum( sqrt( diff(x).^2 + diff(y).^2 ) ) ];       % Distance entre les points
    t = t / t(end);                                             % Abscisse curviligne
    tI = 0:(1/(nbPts-1)):1;

    xI = spline( t, x, tI );
    yI = spline( t, y, tI );

    ptsI = [xI; yI]';