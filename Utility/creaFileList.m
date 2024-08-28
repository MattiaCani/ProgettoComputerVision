% Ottieni la posizione corrente
currentFolder = pwd;

% Ottieni il nome dello script corrente (incluso l'estensione .m)
currentScriptFile = [mfilename('fullpath'), '.m'];

% Chiedi all'utente il nome del file .mat da salvare
fileMatName = input('Inserisci il nome del file .mat da salvare (es. file_list.mat): ', 's');

% Chiedi all'utente l'etichetta da assegnare ai file
labelValue = input('Inserisci l''etichetta (intero) da assegnare ai file: ');

% Nome del file da escludere
excludeFiles = {currentScriptFile, fullfile(currentFolder, fileMatName)};

% Ottieni la lista di tutti i file nelle sottocartelle
allFiles = dir(fullfile(currentFolder, '**', '*.*'));

% Inizializza la cella per memorizzare i percorsi relativi e le etichette
file_list = {};
labels = [];

% Loop per estrarre i percorsi relativi dei file
for i = 1:length(allFiles)
    % Escludi le cartelle
    if ~allFiles(i).isdir
        % Ottieni il percorso completo del file corrente
        currentFilePath = fullfile(allFiles(i).folder, allFiles(i).name);
        
        % Controlla se il file è nello script corrente o file_list.mat
        if ~ismember(currentFilePath, excludeFiles)
            % Ottieni il percorso relativo rimuovendo il percorso di base
            relativePath = fullfile(allFiles(i).folder(length(currentFolder)+2:end), allFiles(i).name);
            % Aggiungi il percorso alla lista
            file_list{end+1, 1} = relativePath;
            % Aggiungi l'etichetta corrispondente alla lista delle etichette
            labels(end+1, 1) = labelValue;
        end
    end
end

% Salva le variabili file_list e labels nel file .mat specificato
save(fileMatName, 'file_list', 'labels');

% Pulisce la workspace
clear;
