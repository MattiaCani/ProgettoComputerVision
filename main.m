% Caricamento del file .mat contenente i percorsi delle immagini e le etichette
data = load('Images/file_list_ridotto.mat'); 
file_list = data.file_list; 
labels = data.new_labels; 


radius = 1; % Raggio del cerchio di campionamento
neighbors = 8; % Numero di punti di campionamento
mapping = getmapping(neighbors, 'u2'); 
mode = 'h'; % Modalità per ottenere l'istogramma

% Inizializza le variabili per memorizzare i risultati
LBP_features = []; % Matrice per memorizzare le caratteristiche LBP
image_labels = []; % Vettore per memorizzare le etichette delle immagini
error=0;
% Cicla attraverso ciascun percorso di immagine
for i = 1:(length(file_list))
    % Carica l'immagine
    image_path = file_list{i};
    
    try
        % Tenta di leggere l'immagine
        image = imread(image_path);
        
        % Converti in scala di grigi se necessario
        if size(image, 3) == 3 % Se l'immagine è a colori, converti in scala di grigi
            image = rgb2gray(image);
        end
        
        % Calcola la LBP per l'immagine corrente
        LBP = lbp(image, radius, neighbors, mapping, mode);
        
        % Aggiungi le caratteristiche e l'etichetta alla matrice delle caratteristiche e al vettore delle etichette
        LBP_features = [LBP_features; LBP];
        image_labels = [image_labels; labels(i)];
        
    catch ME
        % Se c'è un errore, visualizza un messaggio e continua
        %fprintf('Errore nel caricamento o nella conversione di una immagine\n');
        %fprintf('Errore: %s\n', ME.message);
        error = error+1;
        continue;
    end
end
disp(error);    %se questo è 0, sta leggendo tutte le immagini

% Dividi i dati in training e test set
cv = cvpartition(image_labels, 'HoldOut', 0.3); % 70% training, 30% test
trainIdx = training(cv);
testIdx = test(cv);

trainData = LBP_features(trainIdx, :);
trainLabels = image_labels(trainIdx);
testData = LBP_features(testIdx, :);
testLabels = image_labels(testIdx);

k = 5;
classifier = fitcknn(trainData, trainLabels, 'NumNeighbors', k);

% Predici le etichette del test set
predictedLabels = predict(classifier, testData);

% Calcola l’accuratezza
% accuracy = sum(predictedLabels == testLabels) / length(testLabels);
% disp(['Accuratezza: ', num2str(accuracy)]);

% Calcola altre metriche di accuratezza (precision, recall, f1-score)
confMat = confusionmat(testLabels, predictedLabels);

% Precision per ogni classe
% precision = diag(confMat) ./ sum(confMat, 2);
% 
% disp('Precision per classe:');
% disp(precision);

% Esempio di matrice di confusione
confusion = confusionmat(testLabels, predictedLabels);

% Calcola le metriche
[microAVG, macroAVG, wAVG, stats] = computeMetrics(confusion);

% Mostra l'accuratezza macro e micro (VANNO MOLTIPLICATE PER 100 PER AVERE LA
% PERCENTUALE)
disp(['Accuratezza Micro-AVG: ', num2str(microAVG(5))]);
disp(['Accuratezza Macro-AVG: ', num2str(macroAVG(5))]);

