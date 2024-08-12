function BoVW = bovw(image, k, mode, trainingImagePaths)
% BoVW Computes the Bag of Visual Words (BoVW) histogram of an image.
%   BoVW = BOVW(IMAGE, K, MODE, TRAININGIMAGEPATHS) computes the BoVW histogram of an image
%   IMAGE using K clusters. MODE can be 'h' for histogram
%   or 'nh' for normalized histogram. TRAININGIMAGEPATHS is a cell array of paths to training images
%   used to create the vocabulary if not already created.

% Check number of input arguments.
narginchk(4, 4);

% Convert image to grayscale if it is not already.
if size(image, 3) == 3
    image = rgb2gray(image);
end

% Detect keypoints and extract local features.
points = detectSURFFeatures(image); 
[features, valid_points] = extractFeatures(image, points, 'Method', 'SURF');

% Load or generate the vocabulary (cluster centers).
if exist('vocab.mat', 'file') == 2
    % Load the existing vocabulary
    data = load('vocab.mat');
    vocab = data.vocab;
else
    % Create vocabulary using training images if not already created
    all_features = [];
    for i = 1:length(trainingImagePaths)
        image_path = trainingImagePaths{i};
        train_image = imread(image_path);
        if size(train_image, 3) == 3
            train_image = rgb2gray(train_image);
        end
        train_points = detectSURFFeatures(train_image);
        [train_features, valid_train_points] = extractFeatures(train_image, train_points, 'Method', 'SURF');
        
        % Ensure that all_features have consistent number of columns
        if isempty(all_features)
            all_features = train_features;
        else
            if size(train_features, 2) == size(all_features, 2)
                all_features = [all_features; train_features];
            else
                warning('Skipping features with inconsistent size: %d', size(train_features, 2));
            end
        end
    end
    
    % Ensure all_features is non-empty and has the correct size
    if isempty(all_features)
        error('No valid features were extracted from the training images.');
    end
    
    % Check dimensions of all_features
    disp('Size of all_features:');
    disp(size(all_features));
    
    % Reduce the number of features to a manageable size
    max_features = 100000; % Adjust this number based on your memory capacity
    if size(all_features, 1) > max_features
        all_features = datasample(all_features, max_features, 1, 'Replace', false);
    end
    
    
    opts = statset('Display', 'final', 'MaxIter', 2000); % Increase MaxIter to 2000
    [~, vocab] = kmeans(all_features, k, 'Options', opts, 'Replicates', 5, 'Start', 'plus');

    % Check dimensions of vocab
    disp('Size of vocab:');
    disp(size(vocab));
    
    % Save the vocabulary in a file for future use
    save('vocab.mat', 'vocab');
end

% Ensure features have the same number of columns as vocab
if size(features, 2) ~= size(vocab, 2)
    error('Features and vocabulary must have the same number of columns.');
end

% Assign each feature to the nearest cluster center.
indices = knnsearch(vocab, features);

% Compute histogram of visual words.
BoVW = histcounts(indices, 1:k+1);

% Normalize histogram if requested.
if strcmp(mode, 'nh')
    BoVW = BoVW / sum(BoVW);
end
end