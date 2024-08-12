% Script di test per la funzione createVocabulary

% Carica i file contenenti i percorsi delle immagini e delle annotazioni
fileListData = load('file_list_ridotto.mat', 'file_list');
annotationListData = load('annotation_list_ridotto.mat', 'annotation_list_ridotto');

pause;

% Estrai i percorsi delle immagini e delle annotazioni
trainingImagePaths = fileListData.file_list;
annotationPaths = annotationListData.annotation_list_ridotto;

% Verifica che il numero di immagini e annotazioni sia lo stesso
if length(trainingImagePaths) ~= length(annotationPaths)
    error('Il numero di immagini e annotazioni deve essere lo stesso.');
end

% Numero di cluster per k-means
k = 100;

% Chiama la funzione createVocabulary
try
    vocab = createVocabulary(trainingImagePaths, annotationPaths, k);
    fprintf('Il vocabolario è stato creato con successo e salvato in vocab.mat.\n');
catch ME
    fprintf('Errore durante l''esecuzione della funzione createVocabulary: %s\n', ME.message);
end

% Verifica se il file vocab.mat esiste e contiene la variabile vocab
if isfile('vocab.mat')
    loadedData = load('vocab.mat');
    if isfield(loadedData, 'vocab')
        fprintf('Il file vocab.mat contiene la variabile vocab.\n');
    else
        fprintf('Il file vocab.mat non contiene la variabile vocab.\n');
    end
else
    fprintf('Il file vocab.mat non è stato creato.\n');
end
