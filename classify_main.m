clc;
% Aggiungi i percorsi delle funzioni se necessario
addpath('Utility');

% Seleziona il file dell'immagine
[file, path] = uigetfile({'*.jpg;*.png;*.jpeg', 'Image Files (*.jpg, *.png, *.jpeg)'}, 'Seleziona un''immagine');

if isequal(file, 0)
    disp('Nessun file selezionato.');
else
    % Costruisci il percorso completo del file
    imagePath = fullfile(path, file);

    % Identifica il sistema operativo e esegui la classificazione
    if ispc
        run('Utility\cambiaslash.m');  % Per Windows
    elseif ismac
        run('Utility/cambiaslash.m');  % Per macOS
    end

    fprintf("- - CLASSIFICAZIONE IMMAGINE CON I DUE MODELLI - - \n");
    fprintf("Hai selezionato il file: %s \n\n", file);
    
    % Classificazione con LBP
    disp("Classificatore LBP:");
    classifyImgLbp(imagePath); % Passa il percorso dell'immagine alla funzione LBP
    disp('.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.');

    % Classificazione con BoVW
    disp("Classificatore BoVW:");
    classifyImgBovw(imagePath); % Passa il percorso dell'immagine alla funzione BoVW
end
