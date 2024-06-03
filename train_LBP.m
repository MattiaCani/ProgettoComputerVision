function classifier = train_LBP()
    % Carica le informazioni necessarie
    train_data = load('train_list.mat');

    % Seleziona le immagini di addestramento e relative etichette
    train_images = train_data.file_list;
    train_labels = train_data.labels;

    % Inizializza una matrice per le caratteristiche LBP
    num_train_images = length(train_images);
    lbp_features_train = zeros(num_train_images, 59, 'single'); % Dimensioni delle caratteristiche LBP

    % Estrai le caratteristiche LBP dalle immagini di addestramento
    for i = 1:num_train_images
        img = imread(fullfile('images', train_images{i}));
        gray_img = rgb2gray(img);
        lbp_features_train(i, :) = single(extractLBPFeatures(gray_img));
    end

    % Addestra un classificatore k-NN utilizzando le caratteristiche LBP estratte
    K = 5; % Numero di vicini
    classifier = fitcknn(lbp_features_train, train_labels, 'NumNeighbors', K);

    % Salva il classificatore su file
    save('classifier_LBP.mat', 'classifier');
end
