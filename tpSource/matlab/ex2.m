clear variables
close all
clc

addpath( genpath( 'src' ) )

%% Choix de l'image
isReal = 1;
if( isReal )    % Image reelle
    img1 = imread( '/media/zineddine/9D1D-BDBE/IT/TP/TP01/TP/girl1.png' );
    img2 = imread( '/media/zineddine/9D1D-BDBE/IT/TP/TP01/TP/girl2.png' );
    img1 = double( rgb2gray( img1 ) );
    img2 = double( rgb2gray( img2 ) );
    subS = 3;
else    % Image test (binaire)
    vBlock = [4, -2];    % Deplacement (x, y) du carre
    isNoise = 1;        % Images bruitees ou pas
    isIntensity = 0;    % Changement d'illumination ou pas
    [img1, img2] = getImgsBW( vBlock, isNoise, isIntensity );
    subS = 1;
end

%% Parametres
typeEstim = 4;  % 1 = block matching, 2 = 4 Step Search, 3 = Lucas & Kanade, 4 = Horn & Schunck, 5 = Bruhn
sImg = size( img1 );    % Taille de l'image
    %-- Block matching
dimB = 2;       % 1/2 taille du bloc
dimR = 5;       % 1/2 taille de la zone de recherche
N = 1;          % Nombre d'estimations / compensations
optionsBM = struct( 'dimB', dimB, 'dimR', dimR );
    %-- 4 Step Search
options4SS = struct( 'dimB', dimB );
    %-- Lucas-Kanade & Bruhn
sW = 8;        % 1/2 largeur de la fenetre de ponderation
typeW = 0;      % Type de la fenetre de ponderation (0 = uniforme, 1 = gaussienne)
optionsLK = struct( 'sW', sW, 'typeW', typeW );
    %-- Horn-Schunck & Bruhn
alpha = 1;      % Regularisation du champ
maxIts = 250;   % Nombre d'iteration
tol = 1e-5;     % Tolerance entre 2 iterations
optionsHS = struct( 'alpha', alpha, 'maxIts', maxIts, 'tol', tol );
    %-- Bruhn
sW = 5;        % 1/2 largeur de la fenetre de ponderation
optionsBruhn = struct( 'alpha', alpha, 'maxIts', maxIts, 'tol', tol, 'sW', sW );
clear dimB dimR sW typeW alpha maxIts tol;

%% Estimation
tic;
switch typeEstim
    case 1         %-- Block matching
        [v, u] = blockMatching( img1, img2, optionsBM );
    case 2         %-- 4 Step Search
        [u, v] = bm4SS( img1, img2, options4SS );
    case 3         %-- Lucas - Kanade
        [u, v] = ofLK( img1, img2, optionsLK );
    case 4         %-- Horn - Schunck
        [u, v] = ofHS( img1, img2, optionsHS );
    case 5         %-- Bruhn
        [u, v] = ofBruhn( img1, img2, optionsBruhn );
end
toc;


%% Display
[X, Y] = meshgrid( 1:sImg(2), 1:sImg(1) );
figure; imagesc( img1 ); axis image; axis off; colormap gray;
hold on;
    if( ~isReal )
        contour( img2, [0.5, 0.5], 'b', 'linewidth', 2 );
    end
    quiver( X(1:subS:end, 1:subS:end), Y(1:subS:end, 1:subS:end), u(1:subS:end, 1:subS:end), v(1:subS:end, 1:subS:end), 2, 'r' );
hold off;
% A
% when we decrease the patch size the precision increase, lock matching ambiguity in homogeneous regions
% 
% If a block is very uniform (e.g., a white square, a black background), many positions in the search window will have almost the same intensity.
% Larger dimB → smoother motion estimates, more robust to noise, but less sensitive to small motions.
% 
% Smaller dimB → more precise motion detection, but more sensitive to noise and errors in homogeneous regions
% %for dimB = 4 Elapsed time is 0.730327 seconds.
% %for dimB = 3  Elapsed time is 0.835508 seconds.
% %for dimB = 2 Elapsed time is 0.834795 seconds.
% %for dimB = 1  Elapsed time is 0.880570 seconds.


% 
% Motion      DimR 
%   0          0
%   0          1     % the real vector cannot be detected barely all the
%   wrong 
%   1          0     % huge noise and a lot of wrong motion vector !
%   1          1        


% 
% % B texture image 
% 1- Yes the function has been executed without any errors for the motion vector they're refleting the real motion vector, but in the edge of the image, Near the image boundary (top, bottom, left, right), the full search region may not fit inside the image., Blocks near the edges of the image have a truncated search region (fewer candidates)
% 2-   dimr = 5     Elapsed time is 1.069186 seconds., dimr = 20 Elapsed time is 6.863046 seconds.
% the motion vector inside the img are correct in direction but, are too small (wrong detection) and the outlet in the edge have the same size as before, for a small motion
 % for a huge motion with a small size of research zone rdim, we'll get a wrong vector randomly, arround the edge of the first image and the second 
% If dimR is much larger than vBlock, computation time increases but detection is guaranteed.
% 
% If dimR is smaller than vBlock, the algorithm cannot find the correct block position, If dimR < vBlock → Estimated displacement will be smaller than true displacement, or some vectors may be wrong.
% 
% If dimR >= vBlock → Estimated displacement should match vBlock.
% 
% Computation time grows with dimR^2.



% % 3- when we add the intensity to our prototype  : Homogeneous or textured regions:
% Blocks with low variance or high texture may be misinterpreted as moving due to intensity changes.
% 
% Edges and corners of the moving object:
% Because intensity changes, the “best match” in the search region may not correspond to the true displacement.
% 
% Magnitude errors:
% Motion vectors are often smaller or larger than actual displacement, depending on how illumination affects the distance metric.
% 
% Solution: normalize each block's intensity or use correlation-based distance metrics to handle illumination changes.



%[lucas and kande]

%1- NaN/Inf in the linear system: Happens if the local structure tensor is singular (no texture).
%This isn't a crash, but MATLAB may warn about a nearly singular matrix, 
% the velocity field direction is very strong and head to the right direction of the movement, but in same region, it make a small number barely zero, 
% Where the motion is wrong (and why)
% 
% Interior of the white rectangle (flat region)
% 
% What you see: noisy, arbitrary, or near-zero vectors.
% 
% Why: 
% Ix≈Iy≈0
% I
% x
% 	​
% 
% ≈I
% y
% 	​
% 
% ≈0 inside the flat patch → the structure matrix 
% G=A⊤WA
% G=A
% ⊤
% WA is singular. There's no information to solve for two velocity components (underdetermined).
% 
% Uniform black background (flat region)
% 
% Same reason as (1): no gradients → solution is undefined or numerically driven to near-zero by the pseudo-inverse.
% 
% On pure horizontal or pure vertical edges
% 
% What you see: one component of motion can be unstable or zero.
% 
% Why: along a vertical edge 
% Ix
% I
% x
% 	​
% 
%  is large but 
% Iy
% I
% y
% 	​
% 
%  ≈ 0 (and vice versa for horizontal edge). The gradient matrix is rank-1, so only one motion component is observable (aperture problem). LK's 2×2 system is ill-conditioned → solution unreliable (often collapses toward zero in one direction).
% 
% Corners and narrow regions where the local window straddles edge geometry
% 
% Estimates can be biased or inconsistent because the local window mixes pixels from very different regions; results depend heavily on window size and weighting.
% 
% Near image boundaries
% 
% The local window/weights get truncated → structure matrix changes and estimates may be wrong.
% 
% If displacement > window support
% 
% If true motion is larger than the LK window (or initial linearization range), LK may fail or produce wrong vectors unless used iteratively/pyramidal.
%3-3 If Sw it’s small → you follow fine details but the estimate is sensitive to noise or textureless areas.
%If it’s large → more stable and robust but motion is averaged over a bigger area, so boundaries blur.
%for a small widow, we get only the velocity vector on the square conrner,
%which is there's a variation on X and Y , and they are false or very
%noisy, for large windows the direction is very strong, and false in
%tetureless area typically in the black background 

%B - with texture 

% yes the code has been executed without any warning 
% the velocity vector are quite good, despite some of them in the edge of
% the image are incorrect and this is due to the observation window, 

% Displacement near image borders may be inaccurate.
% 
% Uniform weighting (default) treats all pixels in the block equally, which may reduce precision around fine details.
% effect of Gaussian weighting:
% 
% Center pixels contribute more to the displacement calculation.
% 
% Reduces the influence of noisy or less reliable pixels at the block edges.
% 
% Result: motion field is usually smoother and more accurate, especially around edges.


%3- Real image ! 

%A
%in the block matching  : Elapsed time is 7.797211 seconds, 
% in the 4 step method, the method is much faster but less accurate
% Block Matching (typeEstim = 1)
% 
% How it works:
% 
% For each reference block, a full search is done in the search window.
% 
% The displacement that minimizes the distance metric (MAD, SSD, etc.) is chosen.
% 
% Characteristics:
% 
% Accurate, because it checks every candidate block in the window.
% 
% Slower, especially for large search windows or high-resolution images.
% 
% Expected result:
% 
% Dense displacement field.
% 
% Motion vectors near edges and textured regions are precise.
% 
% Borders may still be less accurate if the block goes outside the image.

% -Step Search (typeEstim = 2)
% 
% How it works:
% 
% Instead of evaluating all candidate positions, it performs a hierarchical search:
% 
% Start with a coarse step size.
% 
% Search along a cross pattern (4 positions at a distance equal to the step).
% 
% Reduce step size and repeat until the step = 1.
% 
% Reduces the number of comparisons drastically.
% 
% Characteristics:
% 
% Faster than full block matching.
% 
% May miss the exact minimum if motion is irregular or large.
% 
% Works well when motion is smooth and moderate.

%B 
