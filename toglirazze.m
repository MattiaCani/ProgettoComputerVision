%va eseguito due volte per test_list e due per train_list: una volta su
%data.file_list e l'altra su data.annotation_list per ognuno dei due file

% Carica il file .mat
data = load('train_list.mat');

% Supponiamo che la cell array si chiami 'myCellArray'
myCellArray = data.file_list;

% L'elenco delle parole da cercare e mantenere, separate da punti e virgola
paroleDaMantenere = {'Chihuahua';  %label 1 
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
    'Mexican_hairless'};    %label 118

% Trova le righe da mantenere
righeDaMantenere = false(size(myCellArray));
for i = 1:length(paroleDaMantenere)
    righeDaMantenere = righeDaMantenere | contains(myCellArray, paroleDaMantenere{i});
end

% Mantieni solo le righe
myCellArray = myCellArray(righeDaMantenere);

% Salva la cell array aggiornata nel file .mat
data.file_list = myCellArray;
save('train_list.mat', '-struct', 'data');