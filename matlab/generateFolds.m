%% generateFolds
%   This function does two things:
%       1) It aggregates all of the file names according to class label
%       2) Generates augmented samples from the list
function generateFolds
global segmentedPath
% Common vars
% Change this for local machine
segmentedPath = 'C:\data\Xyllella-Fastidiosa-Dataset\segmented';
foldsPath = 'C:\data\Xyllella-Fastidiosa-Dataset\folds';
NUM_FOLDS = 3;
NUM_SAMPLES = 100;

%% Generate list of file names
% Pass a cell containing the list of subfolders to aggregate into a single
% class
data(1).files = getImageFilenames( ...
    { ...
    'vitus-vinifera\downy-mildew', ...
    'vitus-vinifera\esca-salento', ...
    'vitus-vinifera\gray-mold', ...
    'vitus-vinifera\leafroll', ...
    'vitus-vinifera\powdery-mildew', ...
    'vitus-vinifera\stictocephala-bisonia' ...
    } ...
    );
data(2).files = getImageFilenames( { 'vitus-vinifera\control-salento' } );
data(3).files = getImageFilenames( { 'vitus-vinifera\gy' } );
data(4).files = getImageFilenames( { 'olea-europea\non-leaf-scorch' } );
data(5).files = getImageFilenames( { 'olea-europea\control' } );
data(6).files = getImageFilenames( { 'olea-europea\leaf-scorch' } );

labels = { ...
    'grapeOther', ...
    'grapeControl', ...
    'grapeGY', ...
    'oliveOther', ...
    'oliveControl', ...
    'oliveLeafScorch' ...
    };

%% Generate folds, generate random samples
for fold = 1:NUM_FOLDS
    for i = 1:6 % Per label
        parfor j = 1:NUM_SAMPLES
            % Determine which original samples can be drawn from
            hand = foldBounds( fold, NUM_FOLDS, length(data(i).files) );
            % Pick a random sample from that 'hand'
            drawn = drawFromHand( hand );
            % Get the filename
            imageMeta = data(i).files(drawn);
            % Load the image
            im = imread( fullfile( imageMeta.folder, imageMeta.name ) );
            % Randomly flip with a 50/50 chance
            if rand > 0.5
                im = fliplr(im);
            end
            % Randomly rotate the image [-30,30] degrees
            im = imrotate( im, rand()*60 - 30, 'bicubic', 'crop' );
            % Randomly translate the image by 15%
            im = imtranslate( im, [ rand()*26-13, rand()*26-13 ], ...
                'cubic' );
            % Determine the folder name where this thing goes
            thisFolder = fullfile( foldsPath, num2str(fold), cell2mat( labels( i ) ) );
            if ~exist( thisFolder, 'dir' )
                mkdir( thisFolder )
            end
            imwrite( im, fullfile( thisFolder, [ num2str(j), '.jpg' ] ) );
        end
    end
end
end

% Aggregate the full list of file names, and also randomly order them
function filenames = getImageFilenames( folders )
global segmentedPath
filenames = [];
for folder = folders
    % Use fullfile(.) to generate path to folder
    folderPath = fullfile( segmentedPath, cell2mat(folder) );
    % Change into that directory ...
    cd(folderPath);
    % ... use dir(.) to get the list of .jpg files
    list = dir( '*.jpg' );
    if isempty(list)
        error( [ 'Did not aggregate any file names for folder: ', ...
            folderPath ] ...
            );
    end
    filenames = [ filenames; list ];
end
filenames = filenames( randperm( length(filenames) ) );
end

function res = drawFromHand( hand )
% Hand is a list of indexes, pick a random index
res = max( [ 1, round(rand*length(hand)) ] );
end

function res = foldBounds( i, folds, length )
n = round( length / folds );
res = (1:n) + n*(i - 1);
end