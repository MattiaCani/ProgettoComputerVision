filename = 'file_list_unito.mat';
filename2 = 'augmented_file_list.mat';

% Trova il file nelle cartelle superiori
filepath = findFileInParentFolders(filename);
filepath2 = findFileInParentFolders(filename2);

if isempty(filepath) && isempty(filenpath2)
    error(['File ', filename, ' non trovato nelle cartelle superiori.']);
end

% Carica il file .mat contenente la tabella file_list
data = load(filepath);
data2 = load(filepath2);
file_list = data.file_list; 
file_list_augmented = data2.augmented_file_list;

if ismac
    % Se l'utente usa Mac, sostituisci '\' con '/'
    for i = 1:length(file_list)
        file_list{i} = strrep(file_list{i}, '\', '/');
    end
    for k = 1:length(file_list_augmented)
        file_list_augmented{i} = strrep(file_list_augmented{i}, '\', '/');
    end
    disp("Sistema riconosciuto: MacOS. File list caricati correttamente.")
elseif ispc
    % Se l'utente usa Windows, sostituisci '/' con '\'
    for i = 1:length(file_list)
        file_list{i} = strrep(file_list{i}, '/', '\');
    end
    for k = 1:length(file_list_augmented)
        file_list_augmented{i} = strrep(file_list_augmented{i}, '/', '\');
    end
    disp("Sistema riconosciuto: Windows. File list caricati correttamente.")
else
    error('OS non supportato');
end

% Salva il file_list modificato di nuovo nel file .mat
data.file_list = file_list;
data2.augmented_file_list = file_list_augmented;
save(filepath, '-struct', 'data');
save(filepath2, '-struct', 'data2');

% Funzione ricorsiva per trovare il file nelle cartelle superiori
function filepath = findFileInParentFolders(filename)
    currentFolder = pwd;
    filepath = '';
    
    while true
        % Controlla se il file esiste nella cartella corrente
        if exist(fullfile(currentFolder, filename), 'file') == 2
            filepath = fullfile(currentFolder, filename);
            return;
        end
        
        % Salva la cartella corrente e vai a quella superiore
        parentFolder = fileparts(currentFolder);
        
        % Se la cartella superiore è la stessa o vuota, esci
        if strcmp(currentFolder, parentFolder) || isempty(parentFolder)
            break;
        end
        
        currentFolder = parentFolder;
    end
end
