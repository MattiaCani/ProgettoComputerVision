if ispc
    run('Utility\cambiaslash.m');  % Per Windows
elseif ismac
    run('Utility/cambiaslash.m');  % Per macOS
end

% Seleziona il dataset da usare
flag = input('Che dataset vuoi usare? 1 = dataset normale / 2 = dataset augmented: ');
typeVocab = flag;
addpath("BoVWfunctions");

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

k = 10; % Numero di cluster per BoVW
mode = 'nh'; % Modalità normalizzata per l'istogramma BoVW
numFolds = 5; % Numero di fold per la cross-validation

% Inizializza le variabili per memorizzare i risultati
error = 0;
total_confusion = zeros(numel(unique(labels))); % Inizializza la matrice di confusione 

% Crea la partizione per la cross-validation
cv = cvpartition(labels, 'KFold', numFolds);

for i = 1:cv.NumTestSets
    % Ottiene gli indici del training e test set per questo fold
    trainIdx = training(cv, i);
    testIdx = test(cv, i);

    % Ottiene i file_list e labels di training
    train_file_list = file_list(trainIdx);
    train_labels = labels(trainIdx);
    
    BoVW_features = [];
    image_labels = [];

    % Cicla attraverso ciascun percorso di immagine di training
    for j = 1:length(train_file_list)
        
        image_path = train_file_list{j};

        try
            image = imread(image_path);

            % Converte in scala di grigi se necessario
            if size(image, 3) == 3 
                image = rgb2gray(image);
            end

            % Calcola le caratteristiche BoVW per l'immagine corrente
            BoVW = bovw(image, k, mode, train_file_list, typeVocab); 

            % Aggiunge le caratteristiche e l'etichetta alla matrice delle caratteristiche e al vettore delle etichette
            BoVW_features = [BoVW_features; BoVW];
            image_labels = [image_labels; train_labels(j)];

        catch ME
            
            fprintf('Errore: %s\n', ME.message);
            error = error + 1;
            continue;
        end
    end

    % Ottiene i dati e le etichette di test per questo fold
    test_file_list = file_list(testIdx);
    test_labels = labels(testIdx);

    % Estrae le caratteristiche BoVW per il test set
    test_BoVW_features = [];
    for j = 1:length(test_file_list)
        image_path = test_file_list{j};
        try
            image = imread(image_path);
            if size(image, 3) == 3
                image = rgb2gray(image);
            end
            BoVW = bovw(image, k, mode, train_file_list, typeVocab); 
            test_BoVW_features = [test_BoVW_features; BoVW];
        catch ME
            fprintf('Errore: %s\n', ME.message);
            error = error + 1;
            continue;
        end
    end
    
    
    classifier = fitcknn(BoVW_features, image_labels, 'NumNeighbors', k);

    % Predice le etichette del test set
    predictedLabels = predict(classifier, test_BoVW_features);

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
