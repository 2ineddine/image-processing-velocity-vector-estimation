function [u, v] = ofBruhn( img1, img2, options )
% Estimation du mouvement par la methode de Bruhn
% Inputs:
%     - img1: image a t
%     - img2: image a t+1
%     - options: structure contenant des arguments supplementaires (optionel)
%         Les champs possibles (valeur par defaut) sont:
%         - alpha (1): regularisation du champ
%         - maxIts (250): nombre d'iteration
%         - tol (1e-5): tolerance entre 2 iterations
%         - sW (2): 1/2 largeur de la fenetre de ponderation gaussienne
% Outputs:
%     - u, v: deplacement suivant x et y
% 
% Author: Thomas Dietenbeck
    dOptions = struct( 'alpha', 1, 'maxIts', 250, 'tol', 1e-5, 'sW', 2 );
    %-- Process inputs
    if( ~exist( 'options', 'var' ) )
        options = dOptions;
    elseif( ~isstruct( options ) )
        error( 'Bruhn:Error', 'Options must be a struct' );
    else
        tags = fieldnames( dOptions );
        idxT = find( ~isfield( options, tags ) )';
        for i = idxT
            options.(tags{i}) = dOptions.(tags{i});
        end
    end
    sW = options.sW;
    w = fspecial( 'gaussian', 2*sW+1, (2*sW+1) / 6 );
    alpha = options.alpha;
    maxIts = options.maxIts;
    tol = options.tol;
    
    sImg = size( img1 );        nbPixel = prod( sImg );
    % On normalise les images pour avoir toujours les memes amplitudes de gradient
    img1 = double(img1);
    img1 = ( img1 - min( img1(:) ) ) / ( max( img1(:) ) - min( img1(:) ) );
    
    img2 = double(img2);
    img2 = ( img2 - min( img2(:) ) ) / ( max( img2(:) ) - min( img2(:) ) );

    %-- Parametres
    N = 3;
    meanF = ones( N ) / N^2;
    stop = 0;               its = 0;

    %-- Gradients
    [iX, iY] = gradient( img1 );
    iT = img2 - img1;
    %-- Convolution avec la ponderation (LK)
    wiX2 = conv2( iX.^2, w, 'same' );
    wiXY = conv2( iX.*iY, w, 'same' );
    wiXT = conv2( iX.*iT, w, 'same' );
    wiY2 = conv2( iY.^2, w, 'same' );
    wiYT = conv2( iY.*iT,w, 'same' );
    den = alpha + wiX2 + wiY2;

    u = zeros( sImg );      v = zeros( sImg );
    normV = zeros( sImg );
    while( ~stop && ( its < maxIts ) )
        uM = conv2( u, meanF, 'same' );
        vM = conv2( v, meanF, 'same' );

        num = wiX2 .* uM + wiXY .* vM + wiXT;
        u = uM - num ./ den;
        num = wiXY .* uM + wiY2 .* vM + wiYT;
        v = vM - num ./ den;

        normVNew = sqrt( u.^2 + v.^2 );
        if( ( sum( abs(normVNew - normV) ./ normV ) < (nbPixel*tol) ) )
            stop = 1;
        end
        normV = normVNew;
        its = its + 1;
    end
