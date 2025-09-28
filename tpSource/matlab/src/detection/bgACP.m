function dSeq = bgACP( seq, options )
% Detection du mouvement par apprentissage (ACP)
% Inputs:
%     - seq: la sequence de travail
%     - options: structure contenant des arguments supplementaires (optionel)
%         Les champs possibles (valeur par defaut) sont:
%         - tDeb (1): premiere frame consideree pour la detection
%         - tFin (size(seq,3)): dernière frame consideree pour la detection
%         - N (25): nombre de frames utilisees pour l'apprentissage
%         - M (0.8): pourcentage d'eigenbackgrounds conserves
%         - type (1): 0= ACP pour chaque frame, 1= ACP 1 fois au debut, 
%                     2= 1 seule fois avec N frames parmi les NMax premieres
%		- NMax (100): nombre maximale de frames
% Output:
%     - pSeq: probabilite d'etre en mouvement
% 
% Author: Thomas Dietenbeck
    dOptions = struct( 'tDeb', 1, 'tFin', size(seq, 3), 'N', 25, 'M', 0.8, 'type', 1, 'NMax', 100 );
    %-- Process inputs
    if( ~exist( 'options', 'var' ) )
        options = dOptions;
    elseif( ~isstruct( options ) )
        error( 'bgACP:Error', 'Options must be a struct' );
    else
        tags = fieldnames( dOptions );
        idxT = find( ~isfield( options, tags ) )';
        for i = idxT
            options.(tags{i}) = dOptions.(tags{i});
        end
    end
    tDeb = options.tDeb;
    tFin = options.tFin;
    N = options.N;
    M = options.M;
    type = options.type;
    NMax = options.NMax;
    
    seq = double( seq );
    seq = seq / max( seq(:) );
    sSeq = size( seq );
    sImg = sSeq(1:2);
    dSeq = zeros( sSeq );
    
    if type > 0
        %% ACP 1 fois au debut
        disp( 'ACP' );
        if( type == 1 )
            seqACP = seq(:, :, 1:N);
        else
            idx = randperm( NMax );
            seqACP = seq( :, :, idx(1:N) );
        end	 
        [meanImg, phi, eigenBG] = getEigenBg( seqACP, M );
        nbEigen = size( eigenBG, 3 );
        disp( [ 'Nombre d''eigenbackgrounds conserves = ', num2str( nbEigen ) ] );
        figure; imagesc( meanImg ); axis image; colormap gray; axis off; title( 'Image moyenne' );
        for n = 1:1:nbEigen
            figure; imagesc( eigenBG(:, :, n) ); axis image; colormap gray; axis off;
            title( sprintf( 'Eigenbackground n°%d', n ) );
        end
        
        disp( 'Detection' );
        meanVec = meanImg(:);
        parfor t = tDeb:tFin
            img = seq(:,:,t);
            Bt = phi' * double( img(:) - meanVec );
            Bt = reshape( double( meanVec ) + phi * Bt, sImg );
            dImg = abs( double(img) - Bt );
            dSeq(:, :, t) = dImg / ( max(dImg(:)) + eps );
        end
    else
        %% ACP pour chaque frame
        parfor t = tDeb:tFin
            img = seq(:,:,t);
			if( t - N < 1 )
				seqACP = seq( :, :, 1:N );			% I(i,j) = f(t)
			else
				seqACP = seq( :, :, t-N:t-1 );		% I(i,j) = f(t)
			end
            if( size(seqACP, 3) ~= N )
                seqACP = seq( :, :, deb:deb+N-1 );
            end
            [meanImg, phi, ~] = getEigenBg( seqACP, M );
            meanVec = meanImg(:);
            
            Bt = phi' * double( img(:) - meanVec );
            Bt = reshape( double( meanVec ) + phi * Bt, sImg );
            dImg = abs( double(img) - Bt );
            dSeq(:, :, t) = dImg / ( max(dImg(:)) + eps );
        end
    end
    
    function [bgMean, phi, bgEig] = getEigenBg( seqACP, M )
        [sX, sY, N] = size( seqACP );
        % 1) Mean
        bgMean = mean( seqACP, 3 );
        % 2) Matrice de covariance
        meanImgRep = repmat( bgMean, [1, 1, N] );
        covImg = seqACP - meanImgRep;
        covImg = double( reshape( covImg, [sX * sY, N] ) );

        [V, ~, D] = pca( covImg' );
        nrj = cumsum( D.^2 );

        nbEigen = find( nrj > M * nrj(end), 1 );    % Premiere valeur propre pour laquelle on a plus que M*nrj
        phi = V( :, 1:1:nbEigen );      % M principaux eigenbackground

        bgEig = zeros( [sX, sY, nbEigen] );
        for e = 1:1:nbEigen
            bgEig(:,:,e) = reshape( phi(:,e), [sX, sY] );
        end