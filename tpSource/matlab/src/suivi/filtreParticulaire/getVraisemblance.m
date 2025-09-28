function pYkXk = getVraisemblance( hRef, img, nbPart, xK, l, w, lambda )
    sImg = size( img );
    if( length( sImg ) == 2 )
        sImg(3) = 1;
    end
    nbBin = length( hRef ) / sImg(3);
    
    xMin = round( max( xK(1,:) - l, 1 ) );      xMax = round( min( xK(1,:) + l, sImg(2) ) );
    yMin = round( max( xK(2,:) - w, 1 ) );      yMax = round( min( xK(2,:) + w, sImg(1) ) );
    
    d = zeros( 1, nbPart );
    for i = 1:1:nbPart
        subI = img( yMin(i):yMax(i), xMin(i):xMax(i), : );
        hImg = getHisto( subI, nbBin );
        d(i) = getDistance( hRef, hImg );
    end
    pYkXk = exp( -lambda * d.^2 );