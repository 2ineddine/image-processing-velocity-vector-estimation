clear variables
close all
clc

addpath( genpath( 'src' ) )

dataPath = '/media/zineddine/9D1D-BDBE/IT/TP/TP01/TP/';
seqNum = 1;
switch seqNum
    case 1
        seqName = 'metro/';
        refName = 'refMetro.png';
    case 2
        seqName = 'hall/';
        refName = 'refHall.png';
    case 3
        seqName = 'coke/';
        refName = 'refCoke.png';
    case 4
        seqName = 'jump/';
        refName = 'refJump.png';
end
seq = double( readSeq( [dataPath, seqName], 1 ) );
refImg = double( imread( [dataPath, refName] ) );
sSeq = size( seq );

%% Parametres
typeDetect = 3;     % 1 = difference d'images, 2 = ElGammal, 3 = ACP
tDeb = 1;           % Frame de debut de la detection
tFin = sSeq(3);     % Frame de fin de la detection
    %-- Difference d'images

%ex.1. we use the format ( typeDetect, typeDiff )
%ex1.1.a.

% the first method, (1.1), we use a reference image of the background and
% each frame we compare it to the image frame, and than we can detect the
% object in motion !!
%
% for the (1.2), instead of using a reference image we campare two
% consecutive image two the detet the object in motion 
%
% for the (1.3) we use a refrence background but this background, we'll be
% updated in each in each frame using the expression below:
% diff = (Im_ref - Im_frame); Im_ref  = (1 - alpha)*refImg + alpha*currentFrame;
% in the case of the static object:
    % (1.1) == the object remain  in the detection foreground, (the trame
    % inner), and if there's any change in the background is still there
    % (the leaf in the /hall), there's a cast shadow, in this case, not
    % only the shadow cast but also the the light when it change even
    % though is not an object !, the object are detection only as skeleton
    % and the background is more stable, (the fixed object are discarded), 


    %(1.2) = some object are not well detected, like (/coke, the arms ),
    %there is not the sahadow cast, when we increase the 

%ex.1.1.b


% if we increase the Step for the second method, we'll get a noise (fixed
% shadow behind the object in movement, 

%ex.1.1.c remannce for the 3rd method, much brighter 
%ex.1.1.d. when we increase the learning rate the changes deasppear quickly
%


%ex.1.2. 
% the detection is stable but the the new object in the background is still
% detected ! the shadow cost in enhanced and the computational time is
% huge, when we increse the frame number to learn the detection reduce, and
% also the the shadow cast also 
% 
%%
% When you increase nEG, false positives due to noise decrease, but remanence increases—a stationary object stays labelled as foreground longer.
% When you decrease nEG, the detector becomes more sensitive to real changes but also to camera noise and flickering lights.

%%

%%
% for the acp : when the nACP decrease, we should get a shadow cost and the
% unmoved object still detected 
%but if we increase the nACP we'll get the the remanence phenomena, but the
%unmoved objects are partilly sligtly covered 

% when M increse (0.9) --- remanence also the shadow cast, and the remained
% object are removed 
% when M decrease (0.2) -- remanence, best detection, and the unmoved
% object are very detected 
%%

typeDiff = 2;       % Methode de difference: 1 = fond fixe, 2 = 2 images, 3 = fond connu avec mise a jour
tStep = 1;          % Difference de temps entre 2 images successives
alpha = 0.05;       % Facteur d'apprentissage (si typeDiff = 3)
optionsDI = struct( 'tDeb', tDeb, 'tFin', tFin, 'type', typeDiff, 'refImg', refImg, 'tStep', tStep, 'alpha', alpha );
    %-- ElGammal
nEG = 10;           % Nombre de frames utilisees pour l'apprentissage
typeEG = 1;
nMaxEG = sSeq(3);
optionsEG = struct( 'tDeb', tDeb, 'tFin', tFin, 'N', nEG, 'type', typeEG, 'NMax', nMaxEG );
    %-- ACP
nACP = 50;          % Nombre de frames utilisees pour l'apprentissage
M = 0.2;           % Pourcentage d'eigenbackgrounds
typeACP = 1;
nMaxACP = sSeq(3);
optionsACP = struct( 'tDeb', tDeb, 'tFin', tFin, 'N', nACP, 'type', typeACP, 'NMax', nMaxACP, 'M', M );

%% Detection
switch typeDetect
    case 1
		seqD = bgDiffImg( seq, optionsDI );
    case 2          % Elgammal
        seqD = bgElgammal( seq, optionsEG );
    case 3          % ACP sur sequence
		seqD = bgACP( seq, optionsACP );
end

%% Display
figure;
for t = tDeb:1:tFin
    subplot(1, 2, 1); imagesc( seq(:,:,t) ); axis image; axis off; colormap gray;
    subplot(1, 2, 2); imagesc( seqD(:,:,t) ); axis image; axis off; colormap gray; clim( [0, 1] );
    title( [ num2str(t), ' / ', num2str( sSeq(3) ) ] );
    pause(0.1);
end