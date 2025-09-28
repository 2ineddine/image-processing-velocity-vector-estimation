function [xKp1, omegaKp1] = particleFiltering( img, xK, omegaK, nbPart, hRef, l, w, sigma, lambda, alpha )
%----------------------------------------------------------------------%
% Suivi par filtrage particulaire: cette methode fait:
%	- evoluer toutes les particules de t a t+1
%   - met a jour les poids (suivant la vraisemblance) et les normalise
%   - re-echantillonne si besoin
%
%   Entrees:
%       - img: l'image a t+1
%       - xK: les particules a l'instant t (2xnbPart)
%       - omegaK: les poids a l'instant t (1xnbPart)
%       - nbPart: le nombre de particules
%       - sigma: ecart type de la gaussienne (pour l'evolution des particules)
%       - hRef: l'histogramme cible
%       - l: longueur de la boite englobante
%       - w: largeur de la boite englobante
%       - lambda: facteur de decroissance dans la vraisemblance
%       - alpha: facteur pour le re-echantillonnage
%   Sorties:
%       - xKp1: les particules a l'instant t+1 (2xnbPart)
%       - omegaKp1: les poids a l'instant t+1 (1xnbPart)
%----------------------------------------------------------------------%
    sImg = size( img );

    %-- Marche gaussienne des particules
        % randn = N(0, 1) => m + s*randn = N(m, s)
    xKp1 = xK + sigma*randn( 2, nbPart );
    xKp1(1, :) = max( min( xKp1(1, :), sImg(2) ), 1 );
    xKp1(2, :) = max( min( xKp1(2, :), sImg(1) ), 1 );
    %-- Calcul des poids
    pYkXk = getVraisemblance( hRef, img, nbPart, xKp1, l, w, lambda );
    omegaKp1 = omegaK .* pYkXk;
    %-- Normalisation
    omegaKp1 = omegaKp1 / sum( omegaKp1 );
    %--  Reechantillonnage
    if( sum( omegaKp1.^2 ) < alpha * nbPart )
        [xKp1, omegaKp1] = resample( xKp1, omegaKp1, nbPart );
    end
        
                
    function [pS, wS] = resample( p, w, nbPart )
        c = cumsum(w);
        r = rand(nbPart, 1);
        pS = zeros( size( p ) );
        wS = ones( size( w ) ) / nbPart;
        for i = 1:nbPart
            f = find(c > r(i), 1);
            pS(:, i) = p(:, f);
        end

        