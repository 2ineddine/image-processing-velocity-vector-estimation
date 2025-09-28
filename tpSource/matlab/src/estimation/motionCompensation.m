function imgC = motionCompensation( img, u, v )
    sImg = size( img );     % Taille de l'image
    [y, x] = meshgrid( 1:sImg(2), 1:sImg(1) );  % Coordonnees dans l'image a t
    % Ajout du mouvement => coordonnees a t+1
    xC = x + u;
    yC = y + v;
    % Check bounds
    idxOk = (xC >= 1) & (xC <= sImg(1)) & (yC >= 1) & (yC <= sImg(2));
    xC( ~idxOk ) = 1;
    yC( ~idxOk ) = 1;
    % Compensation par interpolation (cas de mouvement subpixelique)
    imgC = img;
    imgI = interp2( img, yC, xC );
    imgC(idxOk) = imgI( idxOk );  % Suppression des pixels hors de l'image