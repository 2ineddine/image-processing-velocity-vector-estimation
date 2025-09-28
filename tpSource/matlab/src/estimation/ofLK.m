function [u, v] = ofLK( img1, img2, options )
% Estimation du mouvement par Lucas & Kanade
% Inputs:
%     - img1: image a t
%     - img2: image a t+1
%     - options: structure contenant des arguments supplementaires (optionel)
%         Les champs possibles (valeur par defaut) sont:
%         - sW (10): 1/2 largeur de la fenetre de ponderation
%         - typeW (1): type de ponderation (0: uniforme, 1:gaussienne)
% Outputs:
%     - u, v: deplacement suivant x et y
% 
% Author: Thomas Dietenbeck

    dOptions = struct( 'sW', 10, 'typeW', 1 );
    %-- Process inputs
    if( ~exist( 'options', 'var' ) )
        options = dOptions;
    elseif( ~isstruct( options ) )
        error( 'beas3D:Error', 'Options must be a struct' );
    else
        tags = fieldnames( dOptions );
        idxT = find( ~isfield( options, tags ) )';
        for i = idxT
            options.(tags{i}) = dOptions.(tags{i});
        end
    end
    sW = options.sW;
    typeW = options.typeW;
    if( typeW == 1 )
        w = fspecial( 'gaussian', 2*sW+1, (2*sW+1) / 6 );
    else	w = ones( 2*sW+1 );
    end
    
    
    sImg = size( img1 );
    % On normalise les images pour avoir toujours les memes amplitudes de gradient
    img1 = double(img1);
    img1 = ( img1 - min( img1(:) ) ) / ( max( img1(:) ) - min( img1(:) ) );
    
    img2 = double(img2);
    img2 = ( img2 - min( img2(:) ) ) / ( max( img2(:) ) - min( img2(:) ) );
    
    %-- Parametres
    W = diag( w(:) );           % Matrice diagonale des poids
    
    %-- Gradients
    [iX, iY] = gradient( img1 );
    iT = img2 - img1;
    
    %-- Cas general
    u = zeros( sImg );      v = zeros( sImg );
    for x = sW+1:1:sImg(1)-sW     % Pour avoir la place du bloc
        for y = sW+1:1:sImg(2)-sW
            subIX = iX( x-sW:x+sW, y-sW:y+sW );
            subIY = iY( x-sW:x+sW, y-sW:y+sW );
            subIT = iT( x-sW:x+sW, y-sW:y+sW );
            
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);
            
            V = (A' * W * A) \ (A' * W * b);
            
            u(x, y) = u(x, y) + V(1);
            v(x, y) = v(x, y) + V(2);
        end
    end
    
    
    %-- Gestion des bords
    %-- x: Haut
    xM = 1;
    for x = 1:1:sW
        i = 2 - (x - sW);
        %-- y: Gauche
        yM = 1;
        for y = 1:1:sW
            j = 2 - (y - sW);
            subIX = iX( xM:x+sW, yM:y+sW );
            subIY = iY( xM:x+sW, yM:y+sW );
            subIT = iT( xM:x+sW, yM:y+sW );
            wTemp = w( i:end, j:end );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
        %-- y: Centre
        for y = sW+1:1:sImg(2)-sW
            subIX = iX( xM:x+sW, y-sW:y+sW );
            subIY = iY( xM:x+sW, y-sW:y+sW );
            subIT = iT( xM:x+sW, y-sW:y+sW );
            
            wTemp = w( i:end, : );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
        %-- y: Droite
        yP = sImg(2);
        for y = (sImg(2)-sW+1):1:sImg(2)
            j = (y + sW) - sImg(2);
            subIX = iX( xM:x+sW, y-sW:yP );
            subIY = iY( xM:x+sW, y-sW:yP );
            subIT = iT( xM:x+sW, y-sW:yP );
            wTemp = w( i:end, 1:end-j );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
    end
    %-- x: Centre
    for x = sW+1:1:sImg(1)-sW
        %-- y: Gauche
        yM = 1;
        for y = 1:1:sW
            j = 2 - (y - sW);
            subIX = iX( x-sW:x+sW, yM:y+sW );
            subIY = iY( x-sW:x+sW, yM:y+sW );
            subIT = iT( x-sW:x+sW, yM:y+sW );
            wTemp = w( :, j:end );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
        %-- y: Droite
        yP = sImg(2);
        for y = (sImg(2)-sW+1):1:sImg(2)
            j = (y + sW) - sImg(2);
            subIX = iX( x-sW:x+sW, y-sW:yP );
            subIY = iY( x-sW:x+sW, y-sW:yP );
            subIT = iT( x-sW:x+sW, y-sW:yP );
            wTemp = w( :, 1:end-j );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
    end
    %-- x: Bas
    xP = sImg(1);
    for x = sImg(1)-sW+1:1:sImg(1)
        i = (x + sW) - sImg(1);
        %-- y: Gauche
        yM = 1;
        for y = 1:1:sW
            j = 2 - (y - sW);
            subIX = iX( x-sW:xP, yM:y+sW );
            subIY = iY( x-sW:xP, yM:y+sW );
            subIT = iT( x-sW:xP, yM:y+sW );
            wTemp = w( 1:end-i, j:end );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
        %-- y: Centre
        for y = sW+1:1:sImg(2)-sW
            subIX = iX( x-sW:xP, y-sW:y+sW );
            subIY = iY( x-sW:xP, y-sW:y+sW );
            subIT = iT( x-sW:xP, y-sW:y+sW );
            
            wTemp = w( 1:end-i, : );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
        %-- y: Droite
        yP = sImg(2);
        for y = (sImg(2)-sW+1):1:sImg(2)
            j = (y + sW) - sImg(2);
            subIX = iX( x-sW:xP, y-sW:yP );
            subIY = iY( x-sW:xP, y-sW:yP );
            subIT = iT( x-sW:xP, y-sW:yP );
            wTemp = w( 1:end-i, 1:end-j );     W = diag( wTemp(:) );
         
            A = [ subIX(:), subIY(:) ];
            b = -subIT(:);            
            V = (A' * W * A) \ (A' * W * b);
            u(x, y) = V(1);     v(x, y) = V(2);
        end
    end