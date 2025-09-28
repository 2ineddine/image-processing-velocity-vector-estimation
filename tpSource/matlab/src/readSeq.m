function seq = readSeq( pName, bw )
    if( ~exist( 'bw', 'var' ) )
        bw = 1;
    end
    a = dir( pName );
    a = a( [a(:).isdir] == 0 );
    lA = length( a );
    
    img = imread( [ pName, a(1).name ] );
    sImg = size( img );
    if( length(sImg) == 2 )        
        sSeq = [ sImg, lA ];
        seq = zeros( sSeq );
        for i = 1:1:lA
            fNum = str2double( a(i).name( 4:end-4 ) );  % imgXXX.png
            img = imread( [ pName, a(i).name ] );
            seq(:, :, fNum) = img;
        end
    elseif( (sImg(3) == 3) && (bw) )   % Color image 2 Gray        
        sSeq = [ sImg(1:2), lA ];
        seq = zeros( sSeq );
        for i = 1:1:lA
            if( a(i).name(1) == 'i' )
                fNum = str2double( a(i).name( 4:end-4 ) );  % imgXXX.png
            else
                fNum = str2double( a(i).name( 1:end-4 ) );  % XXX.jpg
            end
            img = rgb2gray(imread( [ pName, a(i).name ] ));
            seq(:, :, fNum) = img;
        end
    else   % Color image        
        sSeq = [ sImg, lA ];
        seq = zeros( sSeq );
        for i = 1:1:lA
            if( a(i).name(1) == 'i' )
                fNum = str2double( a(i).name( 4:end-4 ) );  % imgXXX.png
            else
                fNum = str2double( a(i).name( 1:end-4 ) );  % XXX.jpg
            end
            img = imread( [ pName, a(i).name ] );
            seq(:, :, :, fNum) = img;
        end
    end
    % 0 <= I (entier) <= 255
    minI = double( min( seq(:) ) );     maxI = double( max( seq(:) ) );
    seq = uint8( 255*( double(seq) - minI ) / ( maxI - minI ) );