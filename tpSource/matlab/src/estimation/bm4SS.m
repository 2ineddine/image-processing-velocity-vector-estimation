function [u, v] = bm4SS( img1, img2, options )
% Estimation du mouvement par block matching 4 Step Search
% Inputs:
%     - img1: image a t
%     - img2: image a t+1
%     - options: structure contenant des arguments supplementaires (optionel)
%         Les champs possibles (valeur par defaut) sont:
%         - dimB (2): 1/2 taille du bloc
%         - dimR (2): espace entre les pixels consideres aux etapes 1, 2 et 3
% Outputs:
%     - u, v: deplacement suivant x et y
% 
% Author: Thomas Dietenbeck
    dOptions = struct( 'dimB', 2, 'dimR', 4 );
    %-- Process inputs
    if( ~exist( 'options', 'var' ) )
        options = dOptions;
    elseif( ~isstruct( options ) )
        error( 'BlockMatching:Error', 'Options must be a struct' );
    else
        tags = fieldnames( dOptions );
        idxT = find( ~isfield( options, tags ) )';
        for i = idxT
            options.(tags{i}) = dOptions.(tags{i});
        end
    end
    dimB = options.dimB;
    dimR = options.dimR;

    % On normalise les images pour avoir toujours les memes amplitudes de gradient
    img1 = double(img1);
    img1 = ( img1 - min( img1(:) ) ) / ( max( img1(:) ) - min( img1(:) ) );    
    img2 = double(img2);
    img2 = ( img2 - min( img2(:) ) ) / ( max( img2(:) ) - min( img2(:) ) );
    
    sImg = size( img1 );
    sX = sImg(1);           sY = sImg(2);
    u = zeros( sImg );      v = zeros( sImg );
    parfor x = dimB+1:(sX-dimB)
        for y = dimB+1:(sY-dimB)
            %-- Bloc de reference
            bRef = img1( (x-dimB):(x+dimB), (y-dimB):(y+dimB) );
            uT = 0;     vT = 0;

            %-- Initialisation
            bImg = img2( (x-dimB):(x+dimB), (y-dimB):(y+dimB) );
            dMin = sum( abs( bImg(:) - bRef(:) ) );

            %-- Step 1
            [uS, vS, dMin] = bmStep14( bRef, img2, sImg, x, y, dMin, dimB, dimR, 0, 0 );
            uT = uT + uS;         vT = vT + vS;

            %-- Step 2 & 3
            i = 2;
            while( ( ( uS ~= 0 ) || ( vS ~= 0 ) ) && ( i < 4 ) )     % Si il y a eu deplacement
                [uS, vS, dMin] = bmStep23( bRef, img2, sImg, x, y, dMin, dimB, dimR, uT, vT, sign( uS ), sign( vS ) );

                uT = uT + uS;         vT = vT + vS;
                i = i + 1;
            end
            %-- Step 4
            [uS, vS] = bmStep14( bRef, img2, sImg, x, y, dMin, dimB, 1, uT, vT );
            u(x, y) = uT + uS;
            v(x, y) = vT + vS;
        end
    end
    
    
    function [uS, vS, dMin] = bmStep14( bRef, img2, sImg, x, y, dMin, dimB, dimR, uT, vT )
        uS = 0;     vS = 0;
        for dX = -dimR:dimR:dimR
            xD = x + uT + dX;
            if( ( xD-dimB > 0 ) && (xD+dimB <= sImg(1)) )
                for dY = -dimR:dimR:dimR
                    yD = y + vT + dY;
                    if( ( yD-dimB > 0 ) && (yD+dimB <= sImg(2)) )
                        bImg = img2( (xD-dimB):(xD+dimB), (yD-dimB):(yD+dimB) );
                        d = sum( abs( bImg(:) - bRef(:) ) );
                        if( d < dMin )
                            uS = dX;        vS = dY;
                            dMin = d;
                        end
                    end
                end
            end
        end
        
    function [uS, vS, dMin] = bmStep23( bRef, img2, sImg, x, y, dMin, dimB, dimR, uT, vT, sU, sV )
        uS = 0;     vS = 0;
        if( sV ~= 0 )           % Droite ou gauche
            if( sU ~= 0 )       % Bas ou Haut
                % Point directement au dessus (dessous)
                dX = sU*dimR;         xD = x + uT + dX;
                if( ( xD-dimB > 0 ) && (xD+dimB <= sImg(1)) )
                    yD = y + vT;
                    if( ( yD-dimB > 0 ) && (yD+dimB <= sImg(2)) )
                        bImg = img2( xD-dimB:xD+dimB, yD-dimB:yD+dimB );
                        d = sum( abs( bImg(:) - bRef(:) ) );
                        if( d < dMin )
                            uS = dX;        vS = 0;
                            dMin = d;
                        end
                    end
                    % Point directement au dessus (dessous) et a droite (gauche)
                    dY = -sV*dimR;        yD = y + vT + dY;
                    if( ( yD-dimB > 0 ) && (yD+dimB <= sImg(2)) )
                        bImg = img2( xD-dimB:xD+dimB, yD-dimB:yD+dimB );
                        d = sum( abs( bImg(:) - bRef(:) ) );
                        if( d < dMin )
                            uS = dX;        vS = dY;
                            dMin = d;
                        end
                    end
                end
            end
            dY = sV*dimR;     yD = y + vT + dY;
            if( ( yD-dimB > 0 ) && (yD+dimB <= sImg(2)) )
                for dX = -dimR:dimR:dimR
                    xD = x + uT + dX;
                    if( ( xD-dimB > 0 ) && (xD+dimB <= sImg(1)) )
                        bImg = img2( xD-dimB:xD+dimB, yD-dimB:yD+dimB );
                        d = sum( abs( bImg(:) - bRef(:) ) );
                        if( d < dMin )
                            uS = dX;        vS = dY;
                            dMin = d;
                        end
                    end
                end
            end
        else                        % Bas ou Haut
            dX = sU*dimR;
            xD = x + uT + dX;
            if( ( xD-dimB > 0 ) && (xD+dimB <= sImg(1)) )
                for dY = -dimR:dimR:dimR
                    yD = y + vT + dY;
                    if( ( yD-dimB > 0 ) && (yD+dimB <= sImg(2)) )
                        bImg = img2( xD-dimB:xD+dimB, yD-dimB:yD+dimB );
                        d = sum( abs( bImg(:) - bRef(:) ) );
                        if( d < dMin )
                            uS = dX;        vS = dY;
                            dMin = d;
                        end
                    end
                end
            end
        end