function BoVW = bovw(image, k, mode, vocab)
    % BoVW Computes the Bag of Visual Words (BoVW) histogram of an image.
    narginchk(4, 4);

    % Verifica che l'immagine sia valida e in scala di grigi
    if isempty(image) || size(image, 3) ~= 1
        error('L''immagine non è valida o non è in scala di grigi.');
    end

    % Rilevamento dei punti SURF e estrazione delle caratteristiche
    try
        points = detectSURFFeatures(image); 
        features = extractFeatures(image, points);
    catch ME
        error('Errore nell''estrazione delle caratteristiche SURF: %s', ME.message);
    end

    % Verifica che le caratteristiche siano state estratte correttamente
    if isempty(features)
        error('Le caratteristiche non sono state estratte correttamente dall''immagine.');
    end

    % Calcolo dell'istogramma BoVW
    try
        indices = knnsearch(vocab, features);
        BoVW = histcounts(indices, 1:k+1);
    catch ME
        error('Errore durante l''assegnazione delle caratteristiche ai cluster: %s', ME.message);
    end

    % Normalizzazione dell'istogramma
    if strcmp(mode, 'nh')
        BoVW = BoVW / sum(BoVW);
    end

    % Verifica che l'istogramma BoVW sia stato creato correttamente
    if isempty(BoVW) || length(BoVW) ~= k
        error('L''istogramma BoVW non è stato creato correttamente.');
    end
end
