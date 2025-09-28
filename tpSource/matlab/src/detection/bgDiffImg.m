function pSeq = bgDiffImg( seq, options )
% Detection du mouvement par difference d'images
% Inputs:
%     - seq: la sequence de travail
%     - options: structure contenant des arguments supplementaires (optionel)
%         Les champs possibles (valeur par defaut) sont:
%         - type (1): le type de detection souhaite (1: reference connue,
%                 2: images successives, 3: reference connue avec mise a jour du fond)
%         - tDeb (1): premiere frame consideree pour la detection
%         - tFin (size(seq,3)): dernière frame consideree pour la detection
%         - refImg (seq(:,:,1)): l'image de reference
%         - tStep (1): difference de temps entre 2 images successives
%         - alpha (0.01): facteur d'apprentissage pour la mise a jour du fond
% Output:
%     - pSeq: sequence de difference (non seuillee)
%
% Author: Thomas Dietenbeck
	dOptions = struct( 'type', 1, 'tDeb', 1, 'tFin', size(seq, 3), 'refImg', seq(:,:,1), 'tStep', 1, 'alpha', 0.01 );
	%-- Process inputs
	if( ~exist( 'options', 'var' ) )
		options = dOptions;
	elseif( ~isstruct( options ) )
		error( 'bgDiffImg:Error', 'Options must be a struct' );
	else
		tags = fieldnames( dOptions );
		idxT = find( ~isfield( options, tags ) )';
		for i = idxT
			options.(tags{i}) = dOptions.(tags{i});
		end
	end
	type = options.type;
	tDeb = options.tDeb;
	tFin = options.tFin;
	refImg = options.refImg;
	tStep = options.tStep;
	alpha = options.alpha;

	seq = double( seq );
	seq = seq / max( seq(:) );

	sSeq = size( seq );
	pSeq = zeros( sSeq );
	switch type
		case 1      % Reference connue, fixe
			refImg = double( refImg );
			refImg = refImg / max( refImg(:) );
			for t = tDeb:tFin
				pSeq(:,:,t) = abs( refImg - seq(:,:,t) );
			end
		case 2      % 2 images
			for t = tDeb+tStep:tFin
				pSeq(:,:,t) = abs( seq(:,:,t) - seq(:,:,t-tStep) );
			end
		case 3      % Reference connue avec mise a jour du fond
			refImg = double( refImg );
			refImg = refImg / max( refImg(:) );
			for t = tDeb:tFin
				pSeq(:,:,t) = abs( refImg - seq(:,:,t) );
				refImg = (1 - alpha) * refImg + alpha * seq(:,:,t);
			end
	end
	pSeq = ( pSeq - min(pSeq(:)) ) ./ ( max(pSeq(:)) - min(pSeq(:)) );
