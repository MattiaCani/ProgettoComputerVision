if ispc
    run('Utility\cambiaslash.m');  % Per Windows
elseif ismac
    run('Utility/cambiaslash.m');  % Per macOS
end

% Richiede all'utente quale dataset utilizzare
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

% Divide i dati in training e test set
cv = cvpartition(labels, 'HoldOut', 0.3); % 70% training, 30% test
trainIdx = training(cv);
testIdx = test(cv);

% Ottiene i file_list e labels di training e test
train_file_list = file_list(trainIdx);
train_labels = labels(trainIdx);
test_file_list = file_list(testIdx);
test_labels = labels(testIdx);


BoVW_features = zeros(sum(trainIdx), k); % Matrice per memorizzare le caratteristiche BoVW
image_labels = zeros(sum(trainIdx), 1); % Vettore per memorizzare le etichette delle immagini

% Cicla attraverso ciascun percorso di immagine di training
for i = 1:length(train_file_list)
   
    image_path = train_file_list{i};
    
    try
        
        image = imread(image_path);
        
        if size(image, 3) == 3 
            image = rgb2gray(image);
        end
        
        % Calcola le caratteristiche BoVW per l'immagine corrente. Se non
        % esiste, viene creato il vocabolario sulle immagini di training
        BoVW = bovw(image, k, mode, train_file_list, typeVocab); 
        
        BoVW_features(i, :) = BoVW;
        image_labels(i) = train_labels(i);
        
    catch ME
        % Se c'è un errore, visualizza un messaggio e continua
        fprintf('Errore: %s\n', ME.message);
        continue;
    end
end

BoVW_test_features = zeros(sum(testIdx), k); 

for i = 1:length(test_file_list)
    % Carica l'immagine di test
    image_path = test_file_list{i};
    
    try
        % Tenta di leggere l'immagine
        image = imread(image_path);
        
        if size(image, 3) == 3 
            image = rgb2gray(image);
        end
        
        % Calcola le caratteristiche BoVW per l'immagine corrente
        BoVW = bovw(image, k, mode, train_file_list, typeVocab); 
        
        BoVW_test_features(i, :) = BoVW;
        
    catch ME
        % Se c'è un errore, visualizza un messaggio e continua
        fprintf('Errore nel test: %s\n', ME.message);
        continue;
    end
end

% Addestra il classificatore
k = 5;
classifier = fitcknn(BoVW_features, image_labels, 'NumNeighbors', k);

% Salva il classificatore in un file .mat
if typeVocab == 1
    save(fullfile('Classifiers', 'classifier_bovw.mat'), 'classifier');
elseif typeVocab == 2
    save(fullfile('Classifiers', 'classifier_bovw_aug.mat'), 'classifier');
end

% Predice le etichette del test set
predictedLabels = predict(classifier, BoVW_test_features);

% Calcola la matrice di confusione
confMat = confusionmat(test_labels, predictedLabels);

[microAVG, macroAVG, wAVG, stats] = metrics(confMat);

% Mostra l'accuratezza 
disp(['Accuratezza Micro-AVG: ', num2str(microAVG(5))]);
disp(['Accuratezza Macro-AVG: ', num2str(macroAVG(5))]);
