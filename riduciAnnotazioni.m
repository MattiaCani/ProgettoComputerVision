% Carica il file .mat esistente che contiene file_list e annotation_list
existing_vars = load('file_list_ridotto.mat');

% Inizializza la variabile annotation_list_ridotto
annotation_list_ridotto = cell(size(existing_vars.file_list));

% Processa ogni elemento di file_list
for i = 1:length(existing_vars.file_list)
    % Ottieni il nome del file con estensione .jpg
    fullFileName = existing_vars.file_list{i};
    
    % Rimuovi l'estensione .jpg
    [~, fileBaseName, ~] = fileparts(fullFileName);
    
    % Assegna il valore della variabile annotation_list all'elemento corrispondente
    % Nota: qui si sta assumendo che annotation_list è ordinata nello stesso modo di file_list
    annotation_list_ridotto{i} = existing_vars.annotation_list{i};
end

% Unisci tutte le variabili esistenti con la nuova variabile in una struttura
combined_vars = existing_vars; % Copia tutte le variabili esistenti
combined_vars.annotation_list_ridotto = annotation_list_ridotto; % Aggiungi la nuova variabile

% Salva tutte le variabili nel nuovo file 'file_list_ridotto_new.mat'
save('file_list_ridotto_new.mat', '-struct', 'combined_vars');

% Messaggio di completamento
disp('Il processo è stato completato:');
disp(['- Nuovo file creato con tutte le variabili, incluso annotation_list_ridotto: file_list_ridotto_new.mat']);

clear;
