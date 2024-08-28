function enhance_dataset(file_list_name, dest_folder)
    % Carica il dataset
    data = load(file_list_name);
    file_list = data.file_list;
    labels = data.labels;
    
    % Crea una cartella per salvare le immagini trasformate
    outputDir = dest_folder;
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Inizializza nuove liste per file_list e labels
    augmented_file_list = {};
    augmented_labels = [];

    for i = 1:length(file_list)
        % Leggi l'immagine
        img = imread(file_list{i});
        
        % --- Eliminazione del Rumore ---
        % Applica filtro mediano 3D
        img_denoised = apply_median_filter(img);
        
        % --- Oversampling/Data Augmentation ---
        % Esempio: Rotazione di 90 gradi
        img_rot90 = imrotate(img_denoised, 90);
        img_rot180 = imrotate(img_denoised, 180);
       
        % Esempio: Ridimensionamento
        img_resized1 = imresize(img_denoised, 1.2);
        img_resized2 = imresize(img_denoised, 0.8);
    
        
        % Salva le immagini originali e trasformate
        [~, name, ext] = fileparts(file_list{i});
        imwrite(img_denoised, fullfile(outputDir, [name, '_denoised', ext]));
        imwrite(img_rot90, fullfile(outputDir, [name, '_denoised_rot90', ext]));
        imwrite(img_rot180, fullfile(outputDir, [name, '_denoised_rot180', ext]));
        imwrite(img_resized1, fullfile(outputDir, [name, '_denoised_resized1', ext]));
        imwrite(img_resized2, fullfile(outputDir, [name, '_denoised_resized2', ext]));
        
        % Aggiorna la lista dei file e le etichette
        baseName = fullfile(outputDir, [name, '_denoised', ext]);
        augmented_file_list = [augmented_file_list; baseName];
        augmented_labels = [augmented_labels; labels(i)];
        
        augmented_file_list = [augmented_file_list; ...
            fullfile(outputDir, [name, '_denoised_rot90', ext]); ...
            fullfile(outputDir, [name, '_denoised_rot180', ext]); ...
            fullfile(outputDir, [name, '_denoised_resized1', ext]); ...
            fullfile(outputDir, [name, '_denoised_resized2', ext])]; 
        
        augmented_labels = [augmented_labels; repmat(labels(i), 4, 1)];
    end

% Salva il nuovo file list e labels
save(fullfile(outputDir, 'augmented_file_list.mat'), 'augmented_file_list', 'augmented_labels');



end