% Carica il file .mat esistente
data = load('file_list_ridotto.mat');

% Estrai il cell array file_list
file_list = data.file_list;

% Definisci le parole da cercare e le loro nuove etichette
words = {
    'Chihuahua';  %label 1 
    'beagle';   %label 13
    'borzoi';   %label 20
    'American_Staffordshire_terrier';   %label 31
    'Yorkshire_terrier';    %label 38
    'standard_schnauzer';   %label 49
    'golden_retriever';     %label 58
    'cocker_spaniel';       %label 70
    'Border_collie';        %label 83
    'Rottweiler';           %label 85
    'German_shepherd';      %label 86
    'Doberman';             %label 87
    'miniature_pinscher';   %label 88
    'boxer';                %label 93
    'French_bulldog';       %label 96
    'Great_Dane';           %label 97
    'Saint_Bernard';        %label 98
    'Syberian_husky';       %label 101
    'Pomeranian';           %label 109
    'chow';                 %label 110
    'standard_poodle';      %label 117
    'Mexican_hairless'
};

% Mappa delle nuove etichette
new_labels_map = containers.Map(words, 1:length(words));

% Prealloca l'array per i nuovi labels con la stessa dimensione di file_list
new_labels = zeros(size(file_list));

% Scorri file_list e assegna le nuove etichette solo per le celle non vuote
for i = 1:length(file_list)
    if ~isempty(file_list{i})
        for j = 1:length(words)
            if contains(file_list{i}, words{j})
                new_labels(i) = new_labels_map(words{j});
                break;
            end
        end
    end
end

% Salva il nuovo array di labels in un file .mat
save('file_list_ridotto.mat', '-append', 'new_labels');