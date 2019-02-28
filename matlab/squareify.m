% The following file is used for raw images that are very tall. It will pad
% the image on the left and right with background pixels.

clear all
close all
clc

folder = '/home/acruz/Xyllella-Fastidiosa-Dataset/raw/olea-europea/non-leaf-scorch/';
saveFolder = '/home/acruz/Xyllella-Fastidiosa-Dataset/segmented/olea-europea/non-leaf-scorch/';

cd( folder );

files = dir( '*.jpg' );

for i=1:length(files)
    %% Set folder/file names
    readFileName = fullfile( folder, files(i).name );
    saveFileName = fullfile( saveFolder, files(i).name );
    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end
    
    im = imread( fullfile( folder, files(i).name ) );
    %% Attempt to segment the image mask and determine crop bounds
    imGray = rgb2gray( im );    % Grayscale
    imEq = imadjust( imGray );    % Adjust tones
    imBW = ~imbinarize( imEq, graythresh( imEq ) );
    imDilated = imclose( imBW, strel('square',5) );
    % Find the first and last vertical points
    imVertProfile = any( imDilated, 2 );
    for i=1:size(im,1)
        if imVertProfile(i)
            firstY = i;
            break;
        end
    end
    for i=size(im,1):-1:1
        if imVertProfile(i)
            lastY = i;
            break;
        end
    end
    % Find the first and last horizontal points
    imHorzProfile = any( imDilated, 1 );
    for i=1:size(im,2)
        if imHorzProfile(i)
            firstX = i;
            break;
        end
    end
    for i=size(im,2):-1:1
        if imHorzProfile(i)
            lastX = i;
            break;
        end
    end
    imCropped = im(firstY:lastY, firstX:lastX,:);
    %% Now, adjust the aspect ratio to be 1:1
    imSquared = padarray( imCropped, ...
        [0 fix((size(imCropped,1)-size(imCropped,2))/2)], 255, ...
        'both' );
    %% Finally, resize the image to 600x600
    imResized = imresize( imSquared, [681 681] );
    %% Save the image
    imwrite( imResized, saveFileName);
end