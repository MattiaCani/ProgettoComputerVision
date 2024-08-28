% Carica il file MAT
data = load('file_list_ridotto.mat');

% Accedi direttamente alla matrice 'new_labels'
new_labels = data.new_labels;

% Cambia a 1 tutti i valori della prima colonna
new_labels(:, 1) = 1;

% Salva la matrice modificata nel file MAT
save('file_list_ridotto.mat', 'new_labels', '-append');

