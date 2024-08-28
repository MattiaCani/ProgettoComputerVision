function [microAVG, macroAVG, wAVG, stats] = metrics(confusion, ID)
    
    if nargin == 1
        % ID = [1:19];  % Se nessun ID è fornito, seleziona un sottoinsieme di metriche
        ID = [1,2,7,11,16]; % Indici delle metriche di interesse
    end
    
    confusion = confusion';  % Trasponi la matrice di confusione
    confusion = double(confusion);

    mNumber = 19;              % Numero di metriche calcolate
    numP = sum(confusion(:));  % Popolazione totale
    len = size(confusion, 1);  % Numero di classi

    if len == 2 % Caso binario
        len = 2;
    end
    
    metrics = zeros(mNumber, len); 
    TP = zeros(1,len);  % Veri positivi
    TN = zeros(1,len);  % Veri negativi
    FP = zeros(1,len);  % Falsi positivi
    FN = zeros(1,len);  % Falsi negativi
    w = zeros(1,len);   % Pesi
    
    confusion(confusion == 0) = eps;  % Sostituisci gli zeri con un piccolo valore positivo

    for k = 1:len
        % Veri positivi                             % | x o o |
        tp = confusion(k,k);                        % | o o o |
        TP(k) = tp;                                 % | o o o |

        % Falsi positivi                            % | o x x |
        fp = sum(confusion(k,:)) - tp;              % | o o o |
        FP(k) = fp;                                 % | o o o |

        % Falsi negativi                            % | o o o |
        fn = sum(confusion(:,k)) - tp;              % | x o o |
        FN(k) = fn;                                 % | x o o |

        % Veri negativi (tutto il resto)            % | o o o |
        tn = numP - (tp + fp + fn);                 % | o x x |
        TN(k) = tn;                                 % | o x x |
        
        w(k) = tp + fn; 
        metrics(:,k) = compute([tp fn;
                                fp tn]);  
    end
    
    microAVG = compute([sum(TP) sum(FN);
                        sum(FP) sum(TN)]);  
                 
    macroAVG = mean(metrics,2);
    
    if len == 1
        wAVG = macroAVG;
    else
        wAVG = sum(metrics.*repmat(w,mNumber,1),2)/numP;
    end

    % if len > 2 % Correzione per balanced accuracy nel caso multiclass
    %    microAVG(19) = macroAVG(11); % BACC multiclass = macroaverage Recall
    %    macroAVG(19) = macroAVG(11); % BACC multiclass = macroaverage Recall
    %    wAVG(19) = macroAVG(11);     % BACC multiclass = macroaverage Recall
    % end
                 
    microAVG = microAVG(ID);
    macroAVG = macroAVG(ID);
    wAVG = wAVG(ID);

    % Nomi delle righe
    name = ["TP"; "FP"; "FN"; "TN"; ...
            "Accuracy"; "Precision"; "FDR"; "FOR"; "NPV"; ...
            "PRV"; "Recall"; "FPR"; "PLR"; "FNR"; "Specificity"; ...
            "NLR"; "DOR"; "IFM"; "MKD"; "F-score"; "G"; "MCC"; "BACC"];
    
    name = [name(1:4); name(4+ID)];

    % Nomi delle colonne
    varNames = ["name"; "classes"; "macroAVG"; "microAVG"; "weightAVG"];

    % Valori delle colonne per ogni classe
    values = [TP; FP; FN; TN; metrics(ID, :)];

    % Tutte le metriche: calcolo anche MAvG e MAvA per multiclass
    if nargin == 1 && len > 1
         name = [name; "MAvG"; "MAvA"];
         values = [values; zeros(1, len); zeros(1, len)];
         microAVG = [microAVG; 0; 0];
         wAVG = [wAVG; 0; 0];
 
         mavg = (prod(TP./(TP+FP))) ^ (1/len); % Media geometrica macro 
         mava = (sum(TP./(TP+FP))) / len;      % Media aritmetica macro
         macroAVG = [macroAVG; mavg; mava];
    end
    
    % OUTPUT: tabella finale
    stats = table(name, values, [0;0;0;0;macroAVG], [0;0;0;0;microAVG], ...
        [0;0;0;0;wAVG], 'VariableNames',varNames);
end

%--------------------------------------------------------------------------

%%
function [oneM] = compute(oneC, bt)

    if nargin == 1
        bt = 1;
    end

    TP = oneC(1,1);         % Veri positivi
    FN = oneC(1,2);         % Falsi negativi
    TN = oneC(2,2);         % Veri negativi
    FP = oneC(2,1);         % Falsi positivi
    P = TP + FN + TN + FP;  % Popolazione totale
    OP = TP + FP;           % Output positivo 
    ON = FN + TN;           % Output negativo
    CP = TP + FN;           % Condizione positiva
    CN = FP + TN;           % Condizione negativa
    ACC = (TP + TN)/P;        % Accuratezza
    PPV = TP/(OP + eps);      % Precisione, valore predittivo positivo
    FDR = FP/(OP + eps);      % Tasso di falsa scoperta
    FOR = FN/(ON + eps);      % Tasso di falsa omissione
    NPV = TN/(ON + eps);      % Valore predittivo negativo
    PRV = CP/(P + eps);       % Prevalenza
    TPR = TP/(CP + eps);      % Recall, tasso di veri positivi, sensibilità, tasso di successo
    FPR = FP/(CN + eps);      % Tasso di falsi positivi
    PLR = TPR/(FPR + eps);    % Rapporto di verosimiglianza positivo
    FNR = FN/(CP + eps);      % Tasso di falsi negativi
    TNR = TN/(CN + eps);      % Tasso di veri negativi, specificità
    NLR = FNR/(TNR + eps);    % Rapporto di verosimiglianza negativo
    DOR = PLR/(NLR + eps);    % Rapporto di probabilità diagnostica
    IFM = TPR + TNR - 1;      % Informedness
    MKD = PPV + NPV - 1;      % Markedness
    Fbeta = (1 + bt^2) * PPV * TPR/(bt^2 * (PPV + TPR + eps)); % F-score
    G = sqrt(PPV * TPR); % G-measure
    MCC = (TP * TN - FP * FN)/(sqrt(OP * ON * CN * CP) + eps); % Coefficiente di correlazione di Matthews
    BACC = ( (TP/(CP + eps)) + (TN/(CN + eps)) ) / 2; % Accuratezza bilanciata
    oneM = [ACC, PPV, FDR, FOR, NPV, PRV, TPR, FPR, PLR, FNR, TNR, NLR, DOR, IFM, MKD, Fbeta, G, MCC, BACC]';     
end