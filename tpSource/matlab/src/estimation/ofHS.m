function [u, v] = ofHS( img1, img2, options )
% Estimation du mouvement par Horn & Schunck
% Inputs:
%     - img1: image a t
%     - img2: image a t+1
%     - options: structure contenant des arguments supplementaires (optionel)
%         Les champs possibles (valeur par defaut) sont:
%         - alpha (1): regularisation du champ
%         - maxIts (250): nombre d'iteration
%         - tol (1e-5): tolerance entre 2 iterations
% Outputs:
%     - u, v: deplacement suivant x et y
% 
% Author: Thomas Dietenbeck
    dOptions = struct( 'alpha', 1, 'maxIts', 250, 'tol', 1e-5 );
    %-- Process inputs
    if( ~exist( 'options', 'var' ) )
        options = dOptions;
    elseif( ~isstruct( options ) )
        error( 'HornSchunck:Error', 'Options must be a struct' );
    else
        tags = fieldnames( dOptions );
        idxT = find( ~isfield( options, tags ) )';
        for i = idxT
            options.(tags{i}) = dOptions.(tags{i});
        end
    end
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
    den = alpha + iX.^2 + iY.^2;

    u = zeros( sImg );      v = zeros( sImg );
    normV = zeros( sImg );
    while( ~stop && ( its < maxIts ) )
        uM = conv2( u, meanF, 'same' );
        vM = conv2( v, meanF, 'same' );

        num = iX .* uM + iY .* vM + iT;
        u = uM - iX .* num ./ den;
        v = vM - iY .* num ./ den;

        normVNew = sqrt( u.^2 + v.^2 );
        if( ( sum( abs(normVNew - normV) ./ normV ) < (nbPixel*tol) ) )
            stop = 1;
        end
        normV = normVNew;
        its = its + 1;
    end
