function pSeq = bgElgammal( seq, options )
% Detection du mouvement par estimateur de densite
% Inputs:
% 	- seq: la sequence de travail
% 	- options: structure contenant des arguments supplementaires (optionel)
% 	  Les champs possibles (valeur par defaut) sont:
% 		- tDeb (1): premiere frame consideree pour la detection
% 		- tFin (size(seq,3)): dernière frame consideree pour la detection
% 		- N (25): nombre de frames utilisees pour l'apprentissage
%		- type (0): type de mise a jour: 0 = a chaque iteration, 1: 1 seule fois avec
%			les N premieres frames, 2: 1 seule fois avec N frames parmi les
%			NMax premieres
%		- NMax (100): nombre maximale de frames
% Output:
% 	- pSeq: probabilite d'etre en mouvement
% 
% Author: Thomas Dietenbeck
    sSeq = size( seq );
    dOptions = struct( 'tDeb', 1, 'tFin', size(seq, 3), 'N', 25, 'type', 0, 'NMax', 100 );
    %-- Process inputs
    if( ~exist( 'options', 'var' ) )
        options = dOptions;
    elseif( ~isstruct( options ) )
        error( 'bgElgammal:Error', 'Options must be a struct' );
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
	type = options.type;
	NMax = min( options.NMax, sSeq(3) );
    
    seq = double( seq );
    seq = ( seq - min( seq(:) ) ) / ( max( seq(:) ) - min( seq(:) ) );

    denS = ( 0.68 * sqrt(2) );
    denP = N * sqrt( 2 * pi );
    sigmaMin = 0.5;
    	
    x = linspace( 0, 1, 255 );
    pX = zeros( [ sSeq(1:2), length(x) ] );
    coord = 0;
    nbPx = sSeq(1) * sSeq(2);
	if( type > 0 )
		if( type == 1 )
			seqPrev = seq( :, :, 1:N );
		elseif( type == 2 )
			idx = randperm( NMax );
			seqPrev = seq( :, :, idx(1:N) );
		end
		sigmaMat = median( abs( diff( seqPrev, [], 3 ) ), 3 ) / denS;
        sigmaMat = max( sigmaMat, sigmaMin );		% Evite les NaN lors de la division
        % Probabilite d'appartenance
		parfor i = 1:length(x)						% au fond
			pX(:, :, i) = sum( exp( -( x(i) - seqPrev ).^2 ./ (2 * sigmaMat.^2 ) ), 3 );
		end
        pX = 1 - pX ./ ( denP * sigmaMat );			% a l'objet
		x = permute( x, [1, 3, 2] );
		coord = reshape( 1:1:nbPx, sSeq(1:2) );
	end
	
    pSeq = zeros( sSeq );
    parfor t = tDeb:tFin
		if( type == 0 )
			if( t - N < 1 )
				seqPrev = seq( :, :, 1:N );			% I(i,j) = f(t)
			else
				seqPrev = seq( :, :, t-N:t-1 );		% I(i,j) = f(t)
			end
			if( size(seqPrev, 3) ~= N )
				seqPrev = seq( :, :, deb:deb+N-1 );
			end

			sigmaMat = median( abs( diff( seqPrev, [], 3 ) ), 3 ) / denS;
			sigmaMat = max( sigmaMat, sigmaMin );   % Evite les NaN lors de la division

			% Probabilite d'appartenance
			p = sum( exp( -( seq(:,:,t) - seqPrev ).^2 ./ (2 * sigmaMat.^2 ) ), 3 );	% au fond
			pSeq(:, :, t) = 1 - p ./ ( denP * sigmaMat );								% a l'objet
		else
			[~, idx] = min( abs( seq(:,:,t) - x ), [ ], 3 );
			pSeq(:, :, t) = pX( coord + nbPx * (idx - 1) );
		end
    end
    tmpP = min( max( pSeq(:,:,tDeb:tFin), 0 ), 1 );        % Saturation ( p E [0; 1] )
    tmpP = ( tmpP - min( tmpP(:) ) )/ ( max( tmpP(:) ) - min( tmpP(:) ) );  % Normalisation
    pSeq(:,:,tDeb:tFin) = tmpP;