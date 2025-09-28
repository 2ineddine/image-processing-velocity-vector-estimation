function [u, v] = blockMatching( img1, img2, options )
% Estimation du mouvement par block matching
% Inputs:
%     - img1: image a t
%     - img2: image a t+1
%     - options: structure contenant des arguments supplementaires (optionel)
%         Les champs possibles (valeur par defaut) sont:
%         - dimB (2): 1/2 taille du bloc
%         - dimR (5): 1/2 hauteur de la zone de recherche
% Outputs:
%     - u, v: deplacement suivant x et y
% 
% Author: Thomas Dietenbeck

    dOptions = struct( 'dimB', 2, 'dimR', 5 );
    %-- Process inputs
    distance_vector = [];
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
    sImg = size(img1);
    sX = sImg(1);           sY = sImg(2);
    u = zeros( sImg );      v = zeros( sImg );

    for x = dimB+1:sX-dimB     % Pour avoir la place du bloc
        for y = dimB+1:sY-dimB
            subR = img1( x-dimB:x+dimB, y-dimB:y+dimB );
            % dMin = flintmax;



            % 
            % if mod(x,20)==0 && mod(y,20)==0  % every 20th pixel
            %     xStart = max(x-dimR,1); xEnd = min(x+dimR,sX);
            %     yStart = max(y-dimR,1); yEnd = min(y+dimR,sY);
            %     ROI = img2(xStart:xEnd, yStart:yEnd);
            % 
            %     figure(1); clf;
            %     subplot(1,2,1); imagesc(subR); colormap gray; axis image;
            %     title(['Reference Block at (',num2str(x),',',num2str(y),')']);
            %     subplot(1,2,2); imagesc(ROI); colormap gray; axis image;
            %     title('Search Region in img2');
            %     drawnow;
            %     pause(0.1);  % short pause to see the figure
            % end
            subI = img2( x-dimB:x+dimB, y-dimB:y+dimB );
            dMin = getDistance( subR, subI );
            uTmp = 0;       vTmp = 0;
            for dX = -dimR:1:+dimR
                xP = x + dX;
                if( ((xP - dimB) >= 1) && ((xP + dimB) <= sX) )
                    for dY = -dimR:1:dimR
                        yP = y + dY;
                        if( ((yP - dimB) >= 1) && ((yP + dimB) <= sY) )
                            subI = img2( xP-dimB:xP+dimB, yP-dimB:yP+dimB );
                            d = getDistance( subR, subI );
                            if( d < dMin )
                                dMin = d;
                                uTmp = dX;
                                vTmp = dY;
                                distance_vector = [distance_vector,d];
                            end
                        end
                    end
                end
            end
            u(x, y) = uTmp;     v(x, y) = vTmp;
        end
    end
    maxi= max(distance_vector);mini = min(distance_vector);
    ten_per = (maxi)/10;
    disp(ten_per);




    function d = getDistance( subR, subI )
        d = sum( abs( subR(:) - subI(:) ) );	% MAD
        % d = sum( ( subR(:) - subI(:) ).^2 );    % MSSD

%%%%%%%%%%%%%%%%%%%%%%%
% function [u, v] = blockMatching(img1, img2, options)
% % Estimation du mouvement par block matching
% % Visualization: reference block, ROI, and final matched block
% 
% dOptions = struct('dimB',2,'dimR',5);
% distance_vector = [];
% 
% %-- Process options
% if ~exist('options','var')
%     options = dOptions;
% elseif ~isstruct(options)
%     error('Options must be a struct');
% else
%     tags = fieldnames(dOptions);
%     idxT = find(~isfield(options, tags))';
%     for i = idxT
%         options.(tags{i}) = dOptions.(tags{i});
%     end
% end
% 
% dimB = options.dimB;
% dimR = options.dimR;
% sImg = size(img1);
% sX = sImg(1); sY = sImg(2);
% u = zeros(sImg); v = zeros(sImg);
% 
% stepVis = 20;  % adjust speed of visualization
% 
% for x = dimB+1:sX-dimB
%     for y = dimB+1:sY-dimB
%         subR = img1(x-dimB:x+dimB, y-dimB:y+dimB);
%         dMin = getDistance(subR, img2(x-dimB:x+dimB, y-dimB:y+dimB));
%         uTmp = 0; vTmp = 0;
%         xBest = x; yBest = y;  % store final matched position
% 
%         % --- Prepare ROI for visualization ---
%         if mod(x,stepVis)==0 && mod(y,stepVis)==0
%             xStart = max(x-dimR,1); xEnd = min(x+dimR,sX);
%             yStart = max(y-dimR,1); yEnd = min(y+dimR,sY);
%             ROI = img2(xStart:xEnd, yStart:yEnd);
% 
%             figure(1); clf;
%             subplot(1,2,1); imagesc(subR); colormap gray; axis image;
%             title(['Reference Block at (',num2str(x),',',num2str(y),')']);
% 
%             subplot(1,2,2); imagesc(ROI); colormap gray; axis image; hold on;
%             title('Search Region with Final Matched Block');
%             % draw ROI boundary
%             rectangle('Position',[1,1,yEnd-yStart+1,xEnd-xStart+1],'EdgeColor','b','LineWidth',1.5);
%         end
% 
%         % --- Block matching search ---
%         for dX = -dimR:dimR
%             xP = x + dX;
%             if xP - dimB < 1 || xP + dimB > sX, continue; end
%             for dY = -dimR:dimR
%                 yP = y + dY;
%                 if yP - dimB < 1 || yP + dimB > sY, continue; end
% 
%                 subI = img2(xP-dimB:xP+dimB, yP-dimB:yP+dimB);
%                 d = getDistance(subR, subI);
% 
%                 if d < dMin
%                     dMin = d;
%                     uTmp = dX;
%                     vTmp = dY;
%                     xBest = xP;
%                     yBest = yP;
%                     distance_vector = [distance_vector, d];
%                 end
%             end
%         end
% 
%         % --- Visualization of the final matched block ---
%         if mod(x,stepVis)==0 && mod(y,stepVis)==0
%             rectangle('Position',[yBest-yStart+1, xBest-xStart+1, 2*dimB+1, 2*dimB+1],...
%                       'EdgeColor','r','LineWidth',2);
%             drawnow;
%             pause(0.1);
%         end
% 
%         u(x,y) = uTmp;
%         v(x,y) = vTmp;
%     end
% end
% 
% disp(['10% of max distance: ', num2str(max(distance_vector)/10)]);
% 
% %------------------------
%     function d = getDistance(subR, subI)
%         d = sum(abs(subR(:)-subI(:))); % MAD
%     end
% 
% end
