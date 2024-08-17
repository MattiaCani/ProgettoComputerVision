% Carica il file .mat contenente la tabella file_list
data = load('file_list_unito.mat'); 
file_list = data.file_list; 

% Sostituisci ogni occorrenza di '\' con '/'
for i = 1:length(file_list)
    file_list{i} = strrep(file_list{i}, '\', '/');
end

% Se vuoi salvare il file_list modificato di nuovo nel file .mat
data.file_list = file_list;
save('file_list_unito.mat', '-struct', 'data');
