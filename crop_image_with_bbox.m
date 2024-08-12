function cropped_image = crop_image_with_bbox(image_path, annotation_path)
    % Legge l'immagine originale
    image = imread(image_path);
    
    % Legge il file di annotazione XML
    xDoc = xmlread(annotation_path);
    
    % Estrae i valori dei bounding box dal file di annotazione
    xmin = str2double(xDoc.getElementsByTagName('xmin').item(0).getTextContent());
    ymin = str2double(xDoc.getElementsByTagName('ymin').item(0).getTextContent());
    xmax = str2double(xDoc.getElementsByTagName('xmax').item(0).getTextContent());
    ymax = str2double(xDoc.getElementsByTagName('ymax').item(0).getTextContent());
    
    %pausa debug
    %pause(0.05);

    % Ritaglia l'immagine utilizzando i bounding box
    cropped_image = imcrop(image, [xmin, ymin, xmax-xmin, ymax-ymin]);
    
    % Verifica se l'immagine ritagliata è vuota o non valida
    if isempty(cropped_image)
        error('L''immagine ritagliata è vuota o non valida. Verifica i dati di annotazione.');
    end

    % Stampa il percorso dell'immagine croppata
    %fprintf('Immagine croppata: %s\n', image_path);
end
