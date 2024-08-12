function vocab = createVocabulary(trainingImagePaths, annotationPaths, k)
    all_features = [];
    for i = 1:length(trainingImagePaths)
        image_path = trainingImagePaths{i};
        annotation_path = "annotation/Annotation/" + annotationPaths{i}; % Percorso dell'annotazione corrispondente
        
        try
            % Verifica se il file di immagine esiste
            if ~isfile(image_path)
                error('Il file immagine %s non esiste.', image_path);
            end
            
            % Leggi l'immagine
            image = imread(image_path);
            
            % Usa la funzione di supporto per ritagliare l'immagine
            cropped_image = crop_image_with_bbox(image_path, annotation_path);
            
            % Se l'immagine è RGB, convertirla in scala di grigi
            if size(cropped_image, 3) == 3
                cropped_image = rgb2gray(cropped_image);
            end

            % Rileva i punti SURF e estrai le caratteristiche
            points = detectSURFFeatures(cropped_image);
            [features, valid_points] = extractFeatures(cropped_image, points);
            
            % Aggiungi le caratteristiche estratte alla lista complessiva
            if size(features, 2) > 1
                all_features = [all_features; features];
                fprintf('Feature estratte dall''immagine %s: %d\n', image_path, size(features, 1));
            else
                fprintf('Le caratteristiche estratte da %s non sono sufficienti.\n', image_path);
            end
        catch ME
            fprintf('Errore durante l''estrazione delle caratteristiche dall''immagine %s: %s\n', image_path, ME.message);
            continue;
        end
    end

    % Verifica che all_features abbia il giusto formato
    if size(all_features, 2) < 1
        error('Le caratteristiche aggregate non hanno una dimensione sufficiente per il clustering.');
    end

    fprintf('Dimensione di all_features: %s\n', mat2str(size(all_features)));
    
    % Esegui kmeans per creare il vocabolario
    try
        [vocab, ~] = kmeans(all_features, k, 'MaxIter', 1000, 'Display', 'final', 'Replicates', 5, 'Options', statset('UseParallel', 1));
    catch ME
        error('Errore durante l''esecuzione del clustering kmeans: %s', ME.message);
    end
    
    % Verifica che il vocabolario sia una matrice
    if size(vocab, 1) ~= k || size(vocab, 2) ~= size(all_features, 2)
        error('Il vocabolario non ha le dimensioni corrette. Dimensione ottenuta: [%d, %d]', size(vocab, 1), size(vocab, 2));
    end

    % Salva il vocabolario
    save('vocab.mat', 'vocab');
end
