function [histo] = getHisto( img, nbBin )
    sImg = size(img);
    if( length( sImg ) == 2 )
        sImg(3) = 1;
    end
    histo = zeros( 1, nbBin*sImg(3) );
    img = double( img );
%     coul = sImg(3);
%     % Intensite -> numero de bin
%     img( :, :, 1:coul ) = 1 + floor( img * nbBin / 255 );
% 
%     for i = 1:1:sImg(1)
%         for j = 1:1:sImg(2)
%             for k = 1:1:sImg(3)
%                 histo( img(i, j, k) + (k-1)*nbBin ) = histo( img(i, j, k) + (k-1)*nbBin ) + 1;
%             end
%         end
%     end
%     histo(1:coul*nbBin) = histo(1:coul*nbBin) ./ ( sum( histo(1:coul*nbBin) ) );
    
    
    for c = 1:1:sImg(3)
        imgC = img(:,:,c);
        histo( (1:nbBin) + nbBin*(c-1) ) = hist( imgC(:), nbBin );
    end
    histo = histo / sum( histo );
