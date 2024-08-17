% Caricamento del file .mat contenente i percorsi delle immagini e le etichette
data = load('file_list_unito.mat'); 
file_list = data.file_list; 
labels = data.labels; 

k = 10; % Numero di cluster per BoVW
mode = 'nh'; % Modalità normalizzata per l'istogramma BoVW

% Inizializza le variabili per memorizzare i risultati
BoVW_features = []; % Matrice per memorizzare le caratteristiche BoVW
image_labels = []; % Vettore per memorizzare le etichette delle immagini
error = 0;

% Dividi i dati in training e test set
cv = cvpartition(labels, 'HoldOut', 0.3); % 70% training, 30% test
trainIdx = training(cv);
testIdx = test(cv);

% Ottieni i file_list e labels di training
train_file_list = file_list(trainIdx);
train_labels = labels(trainIdx);

% Cicla attraverso ciascun percorso di immagine di training
for i = 1:length(file_list)
    % Carica l'immagine
    image_path = file_list{i};
    
    try
        % Tenta di leggere l'immagine
        image = imread(image_path);
        
        % Converti in scala di grigi se necessario
        if size(image, 3) == 3 % Se l'immagine è a colori, converti in scala di grigi
            image = rgb2gray(image);
        end
        
        % Calcola le caratteristiche BoVW per l'immagine corrente
        BoVW = bovw(image, k, mode, train_file_list); % Passa solo i file di training
        
        % Aggiungi le caratteristiche e l'etichetta alla matrice delle caratteristiche e al vettore delle etichette
        BoVW_features = [BoVW_features; BoVW];
        image_labels = [image_labels; labels(i)];
        
     catch ME
        % Se c'è un errore, visualizza un messaggio e continua
        %fprintf('Errore nel caricamento o nella conversione di una immagine\n');
        fprintf('Errore: %s\n', ME.message);
        error = error + 1;
        continue;
    end
end
disp(error); %se questo è 0, sta leggendo tutte le immagini

% Dividi le caratteristiche BoVW e le etichette nei set di training e test
trainData = BoVW_features(trainIdx, :);
trainLabels = image_labels(trainIdx);
testData = BoVW_features(testIdx, :);
testLabels = image_labels(testIdx);

k = 5;
classifier = fitcknn(trainData, trainLabels, 'NumNeighbors', k);

% Predici le etichette del test set
predictedLabels = predict(classifier, testData);

% Calcola altre metriche di accuratezza (precision, recall, f1-score)
confMat = confusionmat(testLabels, predictedLabels);

% Esempio di matrice di confusione
confusion = confusionmat(testLabels, predictedLabels);

% Calcola le metriche
[microAVG, macroAVG, wAVG, stats] = computeMetrics(confusion);

% Mostra l'accuratezza macro e micro (VANNO MOLTIPLICATE PER 100 PER AVERE LA PERCENTUALE)
disp(['Accuratezza Micro-AVG: ', num2str(microAVG(5))]);
disp(['Accuratezza Macro-AVG: ', num2str(macroAVG(5))]);