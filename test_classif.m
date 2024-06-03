% controlla se esistono i file dei classificatori. Se non esistono,
% chiamare le funzioni per addestrarli
if ~exist('trained_LBP.mat', 'file')
    disp('Modello addestrato non esistente. Addestramento modello...')
    classifyDogBreed_LBP()
else
    disp('Modello addestrato trovato.')
    % Specifica il percorso dell'immagine da classificare
    image_path = 'mushu.jpeg';
    
    % Chiama la funzione per classificare l'immagine
    predicted_breed=classifyDogBreed_LBP(image_path);
    
    % Visualizza la razza predetta della nuova immagine
    disp(['La razza predetta del cane è: ', predicted_breed]);
end


