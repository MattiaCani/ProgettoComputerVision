function img_denoised = apply_median_filter(img)
    img_denoised = img;  % Inizializza l'immagine denoised
    for c = 1:3  % Itera attraverso i canali di colore
        img_denoised(:,:,c) = medfilt3(img(:,:,c), [3 3 3]);
    end
end