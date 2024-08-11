function BoVW = bovw(image, k, mode, trainingImagePaths)
% BoVW Computes the Bag of Visual Words (BoVW) histogram of an image.
%   BoVW = BOVW(IMAGE, K, EXTRACTOR, MODE, TRAININGIMAGEPATHS) computes the BoVW histogram of an image
%   IMAGE using K clusters and a specified EXTRACTOR function. MODE can be 'h' for histogram
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
[features,~]  = extractFeatures(image, points); %funzione di matlab

% Load or generate the vocabulary (cluster centers).
persistent vocab;
if isempty(vocab)
    % Create vocabulary using training images if not already created
    all_features = [];
    for i = 1:length(trainingImagePaths)
        image_path = trainingImagePaths{i};
        train_image = imread(image_path);
        if size(train_image, 3) == 3
            train_image = rgb2gray(train_image);
        end
        train_points = detectSURFFeatures(train_image);
        [train_features, ~] = extractFeatures(train_image, train_points);
        all_features = [all_features; train_features];
    end
    if ~isempty(all_features)
        [~, features_dim] = size(all_features); % Get the feature dimension
        vocab = kmeans(all_features, k); % Create vocabulary
        % Ensure vocab has correct dimensions
        if size(vocab, 2) ~= features_dim
            vocab = [vocab, zeros(k, features_dim - size(vocab, 2))];
        end
    end
    % Save the vocabulary in a file for future use
    save('vocab.mat', 'vocab');
else
    % Load the existing vocabulary if available
    data = load('vocab.mat');
    vocab = data.vocab;
end

% Assign each feature to the nearest cluster center.
%% L'ECCEZIONE STA QUI, UNO DEI DUE TRA VOCAB E FEATURES HA DIMENSIONE SBAGLIATA
indices = knnsearch(vocab, features);   

% Compute histogram of visual words.
BoVW = histcounts(indices, 1:k+1);

% Normalize histogram if requested.
if strcmp(mode, 'nh')
    BoVW = BoVW / sum(BoVW);
end
end