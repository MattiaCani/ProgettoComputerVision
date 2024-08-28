function LBP = lbp(varargin)
% LBP Calcola il Local Binary Pattern (LBP) di un'immagine.
%   LBP = LBP(I, R, N, MAPPING, MODE) calcola i valori LBP di un'immagine in scala di grigi
%   utilizzando N punti di campionamento su un cerchio di raggio R e la
%   tabella di mappatura
%   definita da MAPPING. MODE può essere 'h' per istogramma, 'nh' per istogramma normalizzato, oppure altrimenti restituisce l'immagine LBP.

% Verifica il numero di argomenti in input.
narginchk(1, 5);

image = varargin{1};
d_image = double(image);

if nargin == 1
    spoints = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
    neighbors = 8;
    mapping = 0;
    mode = 'h';
end

if (nargin == 2) && (length(varargin{2}) == 1)
    error('Argomenti di input non validi');
end

if (nargin > 2) && (length(varargin{2}) == 1)
    radius = varargin{2};
    neighbors = varargin{3};
    
    spoints = zeros(neighbors, 2);

    % Passo angolare
    a = 2 * pi / neighbors;
    
    for i = 1:neighbors
        spoints(i, 1) = -radius * sin((i - 1) * a);
        spoints(i, 2) = radius * cos((i - 1) * a);
    end
    
    if(nargin >= 4)
        mapping = varargin{4};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Mapping incompatibile');
        end
    else
        mapping = 0;
    end
    
    if(nargin >= 5)
        mode = varargin{5};
    else
        mode = 'h';
    end
end

if (nargin > 1) && (length(varargin{2}) > 1)
    spoints = varargin{2};
    neighbors = size(spoints, 1);
    
    if(nargin >= 3)
        mapping = varargin{3};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Mapping incompatibile');
        end
    else
        mapping = 0;
    end
    
    if(nargin >= 4)
        mode = varargin{4};
    else
        mode = 'h';
    end   
end

% Determina le dimensioni dell'immagine di input.
[ysize, xsize] = size(image);

miny = min(spoints(:, 1));
maxy = max(spoints(:, 1));
minx = min(spoints(:, 2));
maxx = max(spoints(:, 2));

% Dimensione del blocco, ogni codice LBP viene calcolato all'interno di un blocco di dimensioni bsizey*bsizex
bsizey = ceil(max(maxy, 0)) - floor(min(miny, 0)) + 1;
bsizex = ceil(max(maxx, 0)) - floor(min(minx, 0)) + 1;

% Coordinate dell'origine (0,0) nel blocco
origy = 1 - floor(min(miny, 0));
origx = 1 - floor(min(minx, 0));

% Dimensione minima ammessa per l'immagine di input dipende
% dal raggio dell'operatore LBP utilizzato.
if (xsize < bsizex || ysize < bsizey)
    error('Immagine di input troppo piccola. Deve essere almeno (2*radius+1) x (2*radius+1)');
end

% Calcola dx e dy;
dx = xsize - bsizex;
dy = ysize - bsizey;

% Riempie la matrice dei pixel centrali C.
C = image(origy:origy + dy, origx:origx + dx);
d_C = double(C);

bins = 2^neighbors;

% Inizializza la matrice risultante
LBP = zeros(dy + 1, dx + 1);

for i = 1:neighbors
    y = spoints(i, 1) + origy;
    x = spoints(i, 2) + origx;
    % Calcola i floor, i ceiling e gli arrotondamenti per x e y.
    fy = floor(y); cy = ceil(y); ry = round(y);
    fx = floor(x); cx = ceil(x); rx = round(x);
    % Verifica se è necessaria l'interpolazione.
    if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
        % Non è necessaria l'interpolazione, usa i tipi di dati originali
        N = d_image(ry:ry + dy, rx:rx + dx);
    else
        % Interpolazione necessaria
        ty = y - fy;
        tx = x - fx;

        % Calcola i pesi di interpolazione
        w1 = (1 - tx) * (1 - ty);
        w2 = tx * (1 - ty);
        w3 = (1 - tx) * ty;
        w4 = tx * ty;
        % Calcola i valori dei pixel interpolati
        N = w1 * d_image(fy:fy + dy, fx:fx + dx) + w2 * d_image(fy:fy + dy, cx:cx + dx) + ...
            w3 * d_image(cy:cy + dy, fx:fx + dx) + w4 * d_image(cy:cy + dy, cx:cx + dx);
    end
    
    % Aggiorna la matrice risultante
    D = N >= d_C;   
    v = 2^(i - 1);
    LBP = LBP + v * D;
end

% Applica il mapping se è definito
if isstruct(mapping)
    bins = mapping.num;
    sizarray = size(LBP);
    LBP = LBP(:);
    LBP = mapping.table(LBP + 1);
    LBP = reshape(LBP, sizarray);
end

if (strcmp(mode, 'h') || strcmp(mode, 'hist') || strcmp(mode, 'nh'))
    % Restituisce l'istogramma LBP se il mode è 'hist'.
    LBP = hist(LBP(:), 0:(bins - 1));
    if (strcmp(mode, 'nh'))
        LBP = LBP / sum(LBP);
    end
end