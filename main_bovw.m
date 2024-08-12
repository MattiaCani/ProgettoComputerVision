clear;
clc;
diary('result.txt');
% Caricamento del file .mat contenente i percorsi delle immagini, delle annotazioni e le etichette
data = load('file_list_ridotto_new.mat'); 
file_list = data.file_list; 
annotation_list = data.annotation_list_ridotto; % Supponiamo che ci sia un campo per i percorsi delle annotazioni
labels = data.new_labels; 

k = 5; % Numero di cluster per BoVW
mode = 'nh'; % Modalità normalizzata per l'istogramma BoVW

% Inizializza il contatore di immagini lette correttamente
total_images = length(file_list);
successful_reads = 0;

% Cicla attraverso ciascun percorso di immagine per verificarne la lettura
for i = 1:total_images
    image_path = file_list{i};
    
    try
        % Tenta di leggere l'immagine
        image = imread(image_path);
        
        % Verifica se l'immagine è stata caricata correttamente
        if isempty(image)
            error('L''immagine %s è vuota.', image_path);
        end
        
        % Mostra l'immagine per il debug (commenta questa riga se non necessaria)
        % imshow(image);
        % pause(0.5); % pausa per visualizzare l'immagine

        % Incrementa il contatore delle letture corrette
        successful_reads = successful_reads + 1;
        
    catch ME
        fprintf('Errore nel caricamento dell''immagine %s: %s\n', image_path, ME.message);
        continue;
    end
end

% Stampa il numero di immagini lette correttamente
fprintf('Numero immagini lette correttamente: %d / %d\n', successful_reads, total_images);

% Inizializza le variabili per memorizzare i risultati
BoVW_features = []; % Matrice per memorizzare le caratteristiche BoVW
image_labels = []; % Vettore per memorizzare le etichette delle immagini
errorCount = 0;
maxErrors = 5; % Soglia massima di errori tollerati

disp('Sto per creare il vocabolario...');
pause;
% Crea il vocabolario usando i bounding box dalle annotazioni
vocab = createVocabulary(file_list, annotation_list, k);

disp('piscio dopo creazione vocabolario');
pause;

% Cicla attraverso ciascun percorso di immagine per estrarre le caratteristiche BoVW
for i = 1:length(file_list)
    image_path = file_list{i};
    annotation_path = annotation_list{i}; % Percorso del file di annotazione corrispondente
    
    % Verifica che il file esista
    if ~isfile(image_path) || ~isfile(annotation_path)
        fprintf('Il file %s o il file di annotazione %s non esistono. Salto questa immagine.\n', image_path, annotation_path);
        continue;
    end

    try
        % Ritaglia l'immagine utilizzando i bounding box
        cropped_image = crop_image_with_bbox(image_path, annotation_path);
        imshow(cropped_image);
        
        % Se l'immagine è RGB (3 canali), convertirla in scala di grigi
        if size(cropped_image, 3) == 3
            cropped_image = rgb2gray(cropped_image);
        end

        % Calcola le caratteristiche BoVW per l'immagine ritagliata
        BoVW = bovw(cropped_image, k, mode, vocab);
        
        % Verifica se BoVW è una matrice non vuota e se ha la dimensione corretta
        if ~isempty(BoVW) && isvector(BoVW) && length(BoVW) == k
            % Aggiungi le caratteristiche e l'etichetta alla matrice delle caratteristiche e al vettore delle etichette
            BoVW_features = [BoVW_features; BoVW];
            image_labels = [image_labels; labels(i)];
        else
            fprintf('Errore: La dimensione del vettore BoVW per l''immagine %s non è corretta.\n', image_path);
            errorCount = errorCount + 1;
        end
        
    catch ME
        % Se c'è un errore, visualizza un messaggio e incrementa il contatore di errori
        fprintf('Errore nel caricamento o nella conversione dell''immagine %s: %s\n', image_path, ME.message);
        errorCount = errorCount + 1;
        
        % Se il numero di errori supera la soglia, interrompi l'esecuzione
        if errorCount > maxErrors
            error('Numero massimo di errori raggiunto. Il programma terminerà.');
        end
        
        continue;
    end
end

% Mostra il numero di errori
disp(['Numero di errori: ', num2str(errorCount)]);

% Verifica se sono state aggiunte caratteristiche e etichette
if isempty(BoVW_features) || isempty(image_labels)
    error('BoVW_features o image_labels sono vuoti. Verifica il caricamento delle immagini e l''estrazione delle caratteristiche.');
end

% Dividi i dati in training e test set
try
    cv = cvpartition(image_labels, 'HoldOut', 0.3); % 70% training, 30% test
    trainIdx = training(cv);
    testIdx = test(cv);

    trainData = BoVW_features(trainIdx, :);
    trainLabels = image_labels(trainIdx);
    testData = BoVW_features(testIdx, :);
    testLabels = image_labels(testIdx);
    
    k = 5;
    classifier = fitcknn(trainData, trainLabels, 'NumNeighbors', k);

    % Predici le etichette del test set
    predictedLabels = predict(classifier, testData);

    % Calcola la matrice di confusione
    confMat = confusionmat(testLabels, predictedLabels);

    % Calcola le metriche
    [microAVG, macroAVG, wAVG, stats] = computeMetrics(confMat);

    % Mostra l'accuratezza macro e micro (VANNO MOLTIPLICATE PER 100 PER AVERE LA PERCENTUALE)
    disp(['Accuratezza Micro-AVG: ', num2str(microAVG(5))]);
    disp(['Accuratezza Macro-AVG: ', num2str(macroAVG(5))]);
catch ME
    error('Errore in cvpartition o nella creazione del classificatore: %s', ME.message);
end
