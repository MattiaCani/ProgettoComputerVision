function test_bovw(image_path, k, mode, trainingImagePaths)
    % Funzione di test per la funzione bovw
    % Input:
    %   image_path - Percorso dell'immagine da testare
    %   k - Numero di cluster per BoVW
    %   mode - Modalità normalizzata per l'istogramma BoVW ('nh' o altro)
    %   trainingImagePaths - Cell array dei percorsi delle immagini di addestramento
    
    try
        % Carica l'immagine
        image = imread(image_path);
        
        % Verifica se l'immagine è caricata correttamente
        if isempty(image) || ndims(image) < 2
            error('L''immagine caricata da %s è vuota o ha dimensioni non valide.', image_path);
        end
        
        % Converti in scala di grigi se necessario
        if size(image, 3) == 3
            image = rgb2gray(image);
        end
        
        % Chiama la funzione bovw
        BoVW = bovw(image, k, mode, trainingImagePaths);

        % Verifica se BoVW è una matrice non vuota e se ha la dimensione corretta
        if isempty(BoVW)
            error('La funzione bovw ha restituito un vettore BoVW vuoto per l''immagine %s.', image_path);
        elseif ~isvector(BoVW)
            error('La funzione bovw ha restituito una matrice non vettoriale per l''immagine %s.', image_path);
        elseif length(BoVW) ~= k
            error('Il vettore BoVW restituito per l''immagine %s ha una lunghezza di %d, ma ci si aspettava %d.', image_path, length(BoVW), k);
        end
        
        % Mostra il vettore BoVW
        disp('La funzione bovw ha restituito un vettore valido.');
        disp('Vettore BoVW:');
        disp(BoVW);
        
    catch ME
        % Se c'è un errore, visualizza un messaggio dettagliato
        fprintf('Errore durante il test della funzione bovw per l''immagine %s:\n', image_path);
        fprintf('Messaggio di errore: %s\n', ME.message);
        disp(getReport(ME, 'extended'));
        error('Test della funzione bovw fallito. Interruzione dello script.');
    end
end
