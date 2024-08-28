% Carica tutte le variabili dal file .mat
data = load('augmented_file_list.mat');

% Estrai la tabella 'file_list'
augmented_file_list = data.augmented_file_list;

% Aggiungi il prefisso "Images/" ad ogni elemento della colonna
for i = 1:height(augmented_file_list)
    augmented_file_list{i, 1} = ['Images/' augmented_file_list{i, 1}];
end

% Aggiorna la struttura dei dati con la tabella modificata
data.augmented_file_list = augmented_file_list;

% Salva tutte le variabili nel file .mat, inclusa la tabella aggiornata
save('augmented_file_list.mat', '-struct', 'data');