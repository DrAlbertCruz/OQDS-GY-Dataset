clear all
close all
clc

% Change this for deployment on your local machine
DATA_FOLDER = 'C:\data\Xyllella-Fastidiosa-Dataset';

for groupi = { ...
        'vitus-vinifera\control-salento', ...
        'vitus-vinifera\downy-mildew', ...
        'vitus-vinifera\esca-salento' ...
        'vitus-vinifera\gray-mold', ...
        'vitus-vinifera\gy', ...
        'vitus-vinifera\leafroll', ...
        'vitus-vinifera\powdery-mildew', ...
        'vitus-vinifera\stictocephala-bisonia', ...
        'olea-europea\control', ...
        'olea-europea\leaf-scorch', ...
        'olea-europea\non-leaf-scorch'
    }
    group = cell2mat(groupi);
    loadFolder = fullfile( DATA_FOLDER, 'raw', group );
    saveFolder = fullfile( DATA_FOLDER, 'segmented', group );
    
    cd( loadFolder );
    
    files = dir( '*.jpg' );
    
    % Make sure the save folder exists
    if ~exist(saveFolder, 'dir')
        mkdir(saveFolder);
    end
    
    for i=1:length(files)
        
        % Set folder/file names
        readFileName = fullfile( loadFolder, files(i).name );
        saveFileName = fullfile( saveFolder, files(i).name );
        % Load the images
        im = imread( fullfile( loadFolder, files(i).name ) );
        % Attempt to segment the image mask and determine crop bounds
        imGray = rgb2gray( im );                        % Grayscale
        imEq = imadjust( imGray );                      % Adjust tones
        imBW = ~imbinarize( imEq, graythresh( imEq ) ); % Binarize im mask
        imDilated = imclose( imBW, strel('square',5) ); % Close op to fix holes
        %% Find the first and last vertical points
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
        imCropped = im(firstY:lastY, firstX:lastX,:);   % Cropped image
        % The logic for this code is designed to work with images that are
        % tall. Detect if the image is not tall and flip it.
        isTall = true;
        if size(imCropped,1) < size(imCropped,2)
            isTall = false;
            imCropped = permute(imCropped,[2 1 3]);
        end
        %% Now, adjust the aspect ratio to be 1:1
        imSquared = padarray( imCropped, ...
            [0 fix((size(imCropped,1)-size(imCropped,2))/2)], 255, ...
            'both' );
        % Before resizing, adjust the image to be width-wise if necessary
        if ~isTall
            imSquared = permute(imSquared,[2 1 3]);
        end
        %% Finally, resize the image to 256x256, which is roughly the size o
        imResized = imresize( imSquared, [681 681] );
        %% Save the image
        imwrite( imResized, saveFileName);
    end
end