function classifyImgLbp(pathToClassify)

    addpath("LBPfunctions");
    addpath("Classifiers");

    % Controlla se il file del classificatore esiste
    if exist('classifier_lbp.mat', 'file') == 2 && exist('classifier_lbp_aug.mat', 'file') == 2
        scelta = input(['Quale classificatore LBP vuoi usare? \n' ...
            '1. Addestrato con dataset normale 70% precisione \n' ...
            '2. Addestrato con dataset augmented 80% precisione \n' ...
            'Scelta: ']);
        
        if scelta == 1
            data = load('file_list_unito.mat');
            file_list = data.file_list; 
            labels = data.labels; 
            loadedData = load('classifier_lbp.mat');
        elseif scelta == 2
            data = load('augmented_file_list.mat');
            file_list = data.augmented_file_list; 
            labels = data.augmented_labels; 
            loadedData = load('classifier_lbp_aug.mat');
        end

        classifier = loadedData.classifier;
        
        % Parametri per LBP
        radius = 1; % Raggio del cerchio di campionamento
        neighbors = 8; % Numero di punti di campionamento
        mapping = getmapping(neighbors, 'u2');
        mode = 'h';
       
        image_path = pathToClassify; 
        
        % Carica l'immagine
        image = imread(image_path);

         % Ridimensiona l'immagine a 512x512
        targetSize = [512, 512];
        image = imresize(image, targetSize);
        
        if size(image, 3) == 3
            image = rgb2gray(image);
        end
        
        % Calcola le caratteristiche LBP per l'immagine
        LBP_personal = lbp(image, radius, neighbors, mapping, mode);
        
        % Debug: Dimensione e valori delle caratteristiche
        % disp('Caratteristiche LBP calcolate:');
        % disp(LBP_personal);
        % fprintf('Dimensione delle caratteristiche LBP calcolate: %s\n', mat2str(size(LBP_personal)));
        
        % Predice le probabilità per l'immagine
        [predictedLabel_personal, score] = predict(classifier, LBP_personal);
        % fprintf("predicted personal = %d \n", predictedLabel_personal);
        
        % Mostra le probabilità di appartenenza a ciascuna classe
        classLabels = classifier.ClassNames; 
        
        for i = 1:length(classLabels)
            if classLabels(i) == 1
                nomeClasse = 'cane';
            else
                nomeClasse = 'fiore';
            end

            fprintf('Probabilità di appartenere alla classe %s: %.2f%%\n', nomeClasse, score(i) * 100);
        end
        
        % Mostra l'etichetta predetta
        if predictedLabel_personal == 2
            disp("L'etichetta predetta per la tua immagine è: fiore");
        else
            disp("L'etichetta predetta per la tua immagine è: cane");
        end
    else
        fprintf("Modello non salvato in precedenza. Addestramento . . .");
        main_lbp;
    end
end