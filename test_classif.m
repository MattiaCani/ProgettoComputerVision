% controlla se esistono i file dei classificatori. Se non esistono,
% chiamare le funzioni per addestrarli
if ~exist('classifier_LBP.mat', 'file')
    disp('Addestramento classificatore LBP...')
    train_LBP(); % Sostituisci 'nomeDellaTuaFunzione' con il nome della tua funzione
else
    disp('Il classificatore LBP esiste gia')
end

% if ~exist('classifier_BoVW.mat', 'file')
%     disp('Addestramento classificatore BoVW...')
%     train_BoVW(); % Sostituisci 'nomeDellaTuaFunzione' con il nome della tua funzione
% else
%     disp('Il classificatore BoVW esiste gia')
% end

% Specifica il percorso dell'immagine da classificare
image_path = 'mushu.jpeg';

% Chiama la funzione per classificare l'immagine
predicted_breed = classifyDogBreed(image_path);

% Visualizza la razza predetta della nuova immagine
disp(['La razza predetta del cane è: ', predicted_breed]);