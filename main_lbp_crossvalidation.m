if ispc
    run('Utility\cambiaslash.m');  % Per Windows
elseif ismac
    run('Utility/cambiaslash.m');  % Per macOS
end

%Seleziona il dataset da usare
flag = input('Che dataset vuoi usare? 1 = dataset normale / 2 = dataset augmented: ');
addpath("LBPfunctions");

% Carica il dataset e prepara i dati
if flag == 2
    % Carica il dataset aumentato
    data = load('augmented_file_list.mat'); 
    file_list = data.augmented_file_list; 
    labels = data.augmented_labels; 
elseif flag == 1
    % Carica il dataset croppato
    data = load('file_list_unito.mat'); 
    file_list = data.file_list; 
    labels = data.labels;
else
    error('Flag non valido. Inserire 1 o 2.');
end
radius = 1; % Raggio del cerchio di campionamento
neighbors = 8; % Numero di punti di campionamento
mapping = getmapping(neighbors, 'u2'); 
mode = 'h'; % Modalità per ottenere l'istogramma

numFolds = 5; % Numero di fold per la cross-validation

% Inizializza le variabili per memorizzare i risultati della cross-validation
total_confusion = zeros(numel(unique(labels))); 
error = 0;

% Crea la partizione per la cross-validation
cv = cvpartition(labels, 'KFold', numFolds);

for i = 1:cv.NumTestSets
    % Ottiene gli indici del training e test set per questo fold
    trainIdx = training(cv, i);
    testIdx = test(cv, i);

    % Inizializza le caratteristiche LBP e le etichette per questo fold
    LBP_features_train = [];
    LBP_features_test = [];
    train_labels = [];
    test_labels = [];

    % Cicla attraverso ciascun percorso di immagine
    for j = 1:length(file_list)
        image_path = file_list{j};
        
        try
           
            image = imread(image_path);
            if size(image, 3) == 3 % Se l'immagine è a colori, converti in scala di grigi
                image = rgb2gray(image);
            end

            % Calcola la LBP per l'immagine corrente
            LBP = lbp(image, radius, neighbors, mapping, mode);

            % Aggiunge le caratteristiche e l'etichetta alla matrice delle caratteristiche
            if trainIdx(j)
                LBP_features_train = [LBP_features_train; LBP];
                train_labels = [train_labels; labels(j)];
            elseif testIdx(j)
                LBP_features_test = [LBP_features_test; LBP];
                test_labels = [test_labels; labels(j)];
            end
            
        catch ME
            fprintf('Errore: %s\n', ME.message);
            error = error + 1;
            continue;
        end
    end

    % Addestra il modello sui dati di training
    k = 5;
    classifier = fitcknn(LBP_features_train, train_labels, 'NumNeighbors', k);

    % Predice le etichette del test set
    predictedLabels = predict(classifier, LBP_features_test);

    % Calcola la matrice di confusione per questo fold
    fold_confusion = confusionmat(test_labels, predictedLabels);
    total_confusion = total_confusion + fold_confusion;
    
    % Calcola l'errore per questo fold
    fold_error = sum(predictedLabels ~= test_labels) / numel(test_labels);
    error = error + fold_error;
end

% Calcola l'errore medio su tutti i fold
avg_error = error / cv.NumTestSets;

% Calcola le metriche basate sulla matrice di confusione
[microAVG, macroAVG, wAVG, stats] = metrics(total_confusion);

% Mostra l'errore medio e le metriche
disp(['Errore medio sulla cross-validation: ', num2str(avg_error)]);
disp(['Accuratezza Micro-AVG: ', num2str(microAVG(5))]);
disp(['Accuratezza Macro-AVG: ', num2str(macroAVG(5))]);
