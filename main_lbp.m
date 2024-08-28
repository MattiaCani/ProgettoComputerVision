if ispc
    run('Utility\cambiaslash.m');  % Per Windows
elseif ismac
    run('Utility/cambiaslash.m');  % Per macOS
end

% Richiedi all'utente quale dataset utilizzare
flag = input('Che dataset vuoi usare? 1 = dataset normale / 2 = dataset augmented: ');

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

addpath("LBPfunctions");
radius = 1; % Raggio del cerchio di campionamento
neighbors = 8; % Numero di punti di campionamento
mapping = getmapping(neighbors, 'u2'); 
mode = 'h'; % Modalità per ottenere l'istogramma

% Barra di caricamento per vedere stato dell'esecuzione
h = waitbar(0, 'Elaborazione delle immagini...');

LBP_features = []; % Matrice per memorizzare le caratteristiche LBP
image_labels = []; % Vettore per memorizzare le etichette delle immagini

% Cicla attraverso ciascun percorso di immagine
for i = 1:length(file_list)
    image_path = file_list{i};

    % Aggiorna la barra di caricamento
    waitbar(i/length(file_list), h, sprintf('Elaborazione dell''immagine %d di %d', i, length(file_list)));
    
    try
        image = imread(image_path);
        
        if size(image, 3) == 3
            image = rgb2gray(image);
        end
        
        % Calcola la LBP per l'immagine corrente
        LBP = lbp(image, radius, neighbors, mapping, mode);
        
        LBP_features = [LBP_features; LBP];
        image_labels = [image_labels; labels(i)];
        
    catch ME
        % Se c'è un errore, visualizza un messaggio e continua
        disp(['Errore nella lettura o elaborazione dell''immagine ', image_path, ': ', ME.message]);
        continue;
    end
end

% Chiudo la barra di caricamento
close(h);

% Divide i dati in training e test set
cv = cvpartition(image_labels, 'HoldOut', 0.3); % 70% training, 30% test
trainIdx = training(cv);
testIdx = test(cv);

% Verifica che testIdx non sia vuoto e che file_list contenga abbastanza elementi
if isempty(testIdx)
    error('testIdx è vuoto. Controlla la partizione dei dati.');
end
if length(file_list) < max(testIdx)
    error('file_list non contiene abbastanza elementi per testIdx.');
end

trainData = LBP_features(trainIdx, :);
trainLabels = image_labels(trainIdx);
testData = LBP_features(testIdx, :);
testLabels = image_labels(testIdx);

% Salva le dimensioni delle caratteristiche di addestramento
numFeatures = size(trainData, 2); % Numero di colonne (caratteristiche) in trainData
disp('Numero di caratteristiche di addestramento:');
disp(numFeatures);

k = 5;
classifier = fitcknn(trainData, trainLabels, 'NumNeighbors', k);

% Salva il classificatore in un file .mat
if flag == 1
    save(fullfile('Classifiers', 'classifier_lbp.mat'), 'classifier');
else
    save(fullfile('Classifiers', 'classifier_lbp_aug.mat'), 'classifier');
end

% Predici le etichette del training set
predictedTrainLabels = predict(classifier, trainData);

% Predici le etichette del test set
predictedTestLabels = predict(classifier, testData);

% Calcola la matrice di confusione per il training set
confMatTrain = confusionmat(trainLabels, predictedTrainLabels);

% Calcola la matrice di confusione per il test set
confMatTest = confusionmat(testLabels, predictedTestLabels);

% Visualizzo graficamente la matrice di confusione per il training set
% figure;
% confusionchart(confMatTrain);
% title('Matrice di Confusione - Training Set');
% xlabel('Classi Predette');
% ylabel('Classi Reali');

% Visualizzo graficamente la matrice di confusione per il test set
% figure;
% confusionchart(confMatTest);
% title('Matrice di Confusione - Test Set');
% xlabel('Classi Predette');
% ylabel('Classi Reali');

% Calcola le metriche per il training set
[microAVGTrain, macroAVGTrain, wAVGTrain, statsTrain] = metrics(confMatTrain);

% Calcola le metriche per il test set
[microAVGTest, macroAVGTest, wAVGTest, statsTest] = metrics(confMatTest);

% Mostra l'accuratezza per il training set
% disp(['Accuratezza Micro-AVG Training Set: ', num2str(microAVGTrain(5))]);
% disp(['Accuratezza Macro-AVG Training Set: ', num2str(macroAVGTrain(5))]);

% Mostra l'accuratezza per il test set
% disp(['Accuratezza Micro-AVG Test Set: ', num2str(microAVGTest(5))]);
% disp(['Accuratezza Macro-AVG Test Set: ', num2str(macroAVGTest(5))]);

%%
% Ottieni i nomi dei file di test
testFileList = file_list(testIdx);

% Predici le etichette per i file di test
predictedTestLabels = predict(classifier, testData);

% Apri un file di testo per la scrittura
outputFileName = 'test_results.txt'; % Nome del file di testo
fileID = fopen(outputFileName, 'w'); % 'w' per scrivere

if fileID == -1
    error('Impossibile aprire il file di testo per la scrittura.');
end

% Scrivi l'intestazione nel file di testo
fprintf(fileID, 'File di Test\tEtichetta Predetta\n');

% Stampa i nomi dei file di test e le etichette predette nel file di testo
for i = 1:length(testFileList)
    fprintf(fileID, '%s\t%d\n', testFileList{i}, predictedTestLabels(i));
end

% Chiudi il file di testo
fclose(fileID);

disp(['I risultati sono stati scritti in ', outputFileName]);