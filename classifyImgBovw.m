function classifyImgBovw(pathToClassify)
    
    addpath("BoVWfunctions");
    addpath("Classifiers");

    if exist('classifier_bovw.mat', 'file') == 2 && exist('classifier_bovw_aug.mat', 'file') == 2
        % Testa una nuova immagine personale
        % Carica l'immagine personale
        % Carica il classificatore dal file .mat
        scelta = input(['Quale classificatore BOVW vuoi usare? \n' ...
            '1. Addestrato con dataset normale 70% precisione \n' ...
            '2. Addestrato con dataset augmented 80% precisione \n' ...
            'Scelta: ']);
        
        if scelta == 1
            data = load('file_list_unito.mat');
            file_list = data.file_list; 
            labels = data.labels; 
            loadedData = load('classifier_bovw.mat');
        elseif scelta == 2
            data = load('augmented_file_list.mat');
            file_list = data.augmented_file_list; 
            labels = data.augmented_labels; 
            loadedData = load('classifier_bovw_aug.mat');
        end

        classifier = loadedData.classifier;
        image_path = pathToClassify; 
        
        cv = cvpartition(labels, 'HoldOut', 0.3); % 70% training, 30% test
        trainIdx = training(cv);
        testIdx = test(cv);
        
        % Ottiene i file_list e labels di training
        train_file_list = file_list(trainIdx);
        train_labels = labels(trainIdx);
        
        image = imread(image_path);
        
        % Converte in scala di grigi se necessario
        if size(image, 3) == 3
            image = rgb2gray(image);
        end
        
        typeVocab = scelta;
        % Calcola le caratteristiche BoVW per l'immagine personale
        BoVW_personal = bovw(image, 10, 'nh', train_file_list, typeVocab);
        
        % Predice le probabilità per l'immagine personale
        [~, score] = predict(classifier, BoVW_personal);
        
        % Mostra le probabilità di appartenenza a ciascuna classe
        classLabels = classifier.ClassNames; 
        
        for i = 1:length(classLabels)
            if classLabels(i) == 2
                nomeClasse = 'cane';
            else
                nomeClasse = 'fiore';
            end

            fprintf('Probabilità di appartenere alla classe %s: %.2f%%\n', nomeClasse, score(i) * 100);
        end
        
        % Determina l'etichetta predetta
        [~, predictedIndex] = max(score);
        predictedLabel_personal = classLabels(predictedIndex);
        
        % Mostra il risultato
        if predictedLabel_personal == 1
            disp("L'etichetta predetta per la tua immagine è: fiore");
        else
            disp("L'etichetta predetta per la tua immagine è: cane");
        end
    else
        fprintf("Modello non salvato in precedenza. Addestramento . . .");
        main_bovw;
    end

    
