function predicted_label = classifyDogBreed_LBP(image_path, evaluate_test)
% Percorso del file per il modello addestrato
    model_file = 'trained_LBP.mat';
    % Carica le informazioni necessarie
        train_data = load('train_list.mat');
        test_data = load('test_list.mat');
    
        % Seleziona le immagini di addestramento e relative etichette
        train_images = train_data.file_list;
        train_labels = train_data.labels;
    
        % Seleziona le immagini di test e relative etichette
        test_images = test_data.file_list;
        test_labels = test_data.labels;
    
        % Suddivide i dati di addestramento in set di addestramento e validazione
        rng('default'); % Imposta il seed per la riproducibilità
        [train_idx, val_idx] = dividerand(length(train_labels), 0.8, 0.2); % 80% train, 20% val
    
        train_images_split = train_images(train_idx);
        train_labels_split = train_labels(train_idx);
    
        val_images_split = train_images(val_idx);
        val_labels_split = train_labels(val_idx);
    

    if isfile(model_file)
        % Carica il modello addestrato se esiste
        load(model_file, 'classifier');
        disp('Modello caricato da file.');
    else
        % Inizializza una matrice per le caratteristiche LBP
        num_train_images = length(train_images_split);
        lbp_features_train = zeros(num_train_images, 59, 'single'); % Dimensioni delle caratteristiche LBP
    
        % Estrai le caratteristiche LBP dalle immagini di addestramento
        for i = 1:num_train_images
            img = imread(fullfile('images', train_images_split{i}));
            gray_img = rgb2gray(img);
            lbp_features_train(i, :) = single(extractLBPFeatures(gray_img));
        end
    
        % Addestra un classificatore k-NN utilizzando le caratteristiche LBP
        K = 2; % Numero di vicini
        classifier = fitcknn(lbp_features_train, train_labels_split, 'NumNeighbors', K);

         % Salva il modello addestrato su disco
        save(model_file, 'classifier');
        disp('Modello addestrato e salvato su file.');
    end

    % Valuta le prestazioni del modello utilizzando il set di validazione
    % Estrai le caratteristiche dalle immagini di validazione
    num_val_images = length(val_images_split);
    lbp_features_val = zeros(num_val_images, 59, 'single');

    for i = 1:num_val_images
        img = imread(fullfile('images', val_images_split{i}));
        gray_img = rgb2gray(img);
        
        lbp_features_val(i, :) = single(extractLBPFeatures(gray_img));
    end

    % Valuta le prestazioni del modello sul set di validazione
    val_predicted_labels = predict(classifier, lbp_features_val);
    val_accuracy = sum(val_predicted_labels == val_labels_split) / num_val_images;
    disp(['Accuracy on validation set: ', num2str(val_accuracy)]);

    % Valuta il set di test solo se richiesto
    if nargin > 1 && strcmpi(evaluate_test, 't')
        % Inizializza una matrice per le caratteristiche LBP del set di test
        num_test_images = length(test_images);
        lbp_features_test = zeros(num_test_images, 59, 'single');

        % Estrai le caratteristiche LBP dalle immagini di test
        for i = 1:num_test_images
            img = imread(fullfile('images', test_images{i}));
            gray_img = rgb2gray(img);
            
            lbp_features_test(i, :) = single(extractLBPFeatures(gray_img));
        end

        % Valuta le prestazioni del modello sul set di test
        test_predicted_labels = predict(classifier, lbp_features_test);
        test_accuracy = sum(test_predicted_labels == test_labels) / num_test_images;
        disp(['Accuracy on test set: ', num2str(test_accuracy)]);
    end

    % Classifica la nuova immagine se il percorso è fornito come parametro
    if nargin > 0 && ~isempty(image_path)
        % Carica e pre-processa la nuova immagine
        new_img = imread(image_path);
        new_gray_img = rgb2gray(new_img);

        % Estrai le caratteristiche LBP dalla nuova immagine
        new_lbp_features = single(extractLBPFeatures(new_gray_img));

        % Classifica la nuova immagine utilizzando il classificatore k-NN addestrato
        predicted_label = predict(classifier, new_lbp_features);

        % Restituisci la razza prevista della nuova immagine
        return;
    end
end