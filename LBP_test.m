% Aggiungi il percorso delle funzioni LBP
addpath("LBPfunctions");

% Specifica il percorso del file di immagine da classificare
imagePath = 'mushu.png'; % Modifica questo percorso con il percorso dell'immagine

% Estrai il nome del file senza estensione
[~, imageName, ~] = fileparts(imagePath);

% Carica il modello salvato
modelFile = 'Classifiers/classifier_lbp.mat'; % Modifica questo percorso se necessario
if exist(modelFile, 'file')
    modelData = load(modelFile);
    classifier = modelData.classifier;
else
    error('Il file del modello non esiste. Assicurati di fornire il percorso corretto.');
end

% Parametri LBP
radius = 1; % Raggio del cerchio di campionamento
neighbors = 8; % Numero di punti di campionamento
mapping = getmapping(neighbors, 'u2'); 
mode = 'h'; % Modalità per ottenere l'istogramma

% Leggi e pre-processa l'immagine
try
    image = imread(imagePath);
    % Ridimensiona l'immagine a 512x512
    targetSize = [512, 512];
    image = imresize(image, targetSize);
    
    if size(image, 3) == 3
        image = rgb2gray(image); % Converti in scala di grigi se l'immagine è a colori
    end
    
    % Calcola la LBP per l'immagine
    LBP = lbp(image, radius, neighbors, mapping, mode);
    
    % Predici l'etichetta dell'immagine
    predictedLabel = predict(classifier, LBP);

    % Visualizza il nome del file e l'etichetta predetta
    disp(['Nome dell''immagine: ', imageName]);
    disp(['L''etichetta predetta per l''immagine è: ', num2str(predictedLabel)]);
catch ME
    disp(['Errore nella lettura o elaborazione dell''immagine: ', ME.message]);
end
