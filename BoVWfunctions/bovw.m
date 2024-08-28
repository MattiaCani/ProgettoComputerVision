function BoVW = bovw(image, k, mode, trainingImagePaths, typeVocab)

warning('off', 'all');
narginchk(5, 5);

% Rileva i punti di interesse e estrae le caratteristiche locali.
points = detectSURFFeatures(image); 
[features, valid_points] = extractFeatures(image, points, 'Method', 'SURF');

% Determina il vocabolario in base a typeVocab
if typeVocab == 1
    vocabFile = 'vocab.mat';
elseif typeVocab == 2
    vocabFile = 'vocab_augmented.mat';
else
    error('Valore di typeVocab non valido. Deve essere 1 o 2.');
end

% Carica o crea il vocabolario
if exist(vocabFile, 'file') == 2
    % Carica il vocabolario esistente
    data = load(vocabFile);
    vocab = data.vocab;
    %fprintf('Vocabolario caricato da %s.\n', vocabFile);
else
    % Crea il vocabolario utilizzando le immagini di training se non è stato già creato
    fprintf('Creazione del vocabolario...\n');
    all_features = [];
    for i = 1:length(trainingImagePaths)
        image_path = trainingImagePaths{i};
        train_image = imread(image_path);
        if size(train_image, 3) == 3
            train_image = rgb2gray(train_image);
        end
        train_points = detectSURFFeatures(train_image);
        [train_features, valid_train_points] = extractFeatures(train_image, train_points, 'Method', 'SURF');
        
        % Assicura che all_features abbia un numero coerente di colonne
        if isempty(all_features)
            all_features = train_features;
        else
            if size(train_features, 2) == size(all_features, 2)
                all_features = [all_features; train_features];
            else
                warning('Saltando le caratteristiche con dimensioni inconsistenti: %d', size(train_features, 2));
            end
        end
    end
    
    
    if isempty(all_features)
        error('Nessuna caratteristica valida è stata estratta dalle immagini di addestramento.');
    end
    
    % Riduce il numero di caratteristiche a una dimensione gestibile
    max_features = 100000; 
    if size(all_features, 1) > max_features
        all_features = datasample(all_features, max_features, 1, 'Replace', false);
    end
    
    opts = statset('Display', 'final', 'MaxIter', 2000); 
    [~, vocab] = kmeans(all_features, k, 'Options', opts, 'Replicates', 5, 'Start', 'plus');
    
    % Salva il vocabolario in un file 
    save(vocabFile, 'vocab');
    fprintf('Vocabolario creato e salvato in %s.\n', vocabFile);
end


if size(features, 2) ~= size(vocab, 2)
    error('Le caratteristiche e il vocabolario devono avere lo stesso numero di colonne.');
end


indices = knnsearch(vocab, features);

BoVW = histcounts(indices, 1:k+1);

% Normalizza l'istogramma se richiesto.
if strcmp(mode, 'nh')
    BoVW = BoVW / sum(BoVW);
end
end