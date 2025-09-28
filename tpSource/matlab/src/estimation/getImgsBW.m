function [img1, img2] = getImgsBW( vBlock, isNoise, isIntensity )
    if( ~exist( 'vBlock', 'var' ) )
        vBlock = [1, 2];
    end
    if( ~exist( 'isNoise', 'var' ) )
        isNoise = 0;
    end
    if( ~exist( 'isIntensity', 'var' ) )
        isIntensity = 0;
    end

    N = 64;                 % Taille de l'image
    sFg = N/4 + 1;          % Taille de l'objet
    xFg = N*3/8:N*5/8;      % Position de l'objet a t
    posFg = round( [ xFg - vBlock(1)/2; xFg - vBlock(2)/2 ] );
    
    imgBg = zeros( N, N );
    imgFg = ones( sFg );
    if( isNoise )
        imgBg = imnoise( imgBg, 'gaussian', 0, 0.05 );
        imgFg = imnoise( imgFg, 'gaussian', 0, 0.01 );
    end
    
    img1 = imgBg;       img1( posFg(1, :), posFg(2, :) ) = imgFg;
    img2 = imgBg;
    if( isIntensity )
        img2( posFg(1, :) + vBlock(1), posFg(2, :) + vBlock(2) ) = imgFg / 2 + 3;
    else
        img2( posFg(1, :) + vBlock(1), posFg(2, :) + vBlock(2) ) = imgFg;
    end
