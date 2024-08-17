function [microAVG, macroAVG, wAVG, stats] = computeMetrics(confusion, ID)

    % The input 'confusion' is the the output of the Matlab function
    % 'confusionmat' with its variable NormalizedValues
    
    if nargin == 1
        ID = [1:19];
        %ID = [1,2,7,11,16]; %index for the metrics of interest
    end
    
    confusion = confusion';
    confusion = double(confusion);

    mNumber = 19;              % number of metrics computed
    numP = sum(confusion(:));  % population
    len = size(confusion, 1);

    if len == 2 %nel caso di problema binario prendiamo solo la prima classe
        len = 2;
    end
    
    metrics = zeros(mNumber, len); 
    TP = zeros(1,len);
    TN = zeros(1,len);
    FP = zeros(1,len);
    FN = zeros(1,len);
    w = zeros(1,len);
    
    confusion(confusion == 0) = eps;

    for k = 1:len
        % True positives                           % | x o o |
        tp = confusion(k,k);                       % | o o o |
        TP(k) = tp;                                % | o o o |

        % False positives                          % | o x x |
        fp = sum(confusion(k,:)) - tp;             % | o o o |
        FP(k) = fp;                                % | o o o |

        % False negatives                          % | o o o |
        fn = sum(confusion(:,k)) - tp;             % | x o o |
        FN(k) = fn;                                % | x o o |

        % True negatives (all the rest)            % | o o o |
        tn = numP - (tp + fp + fn);                % | o x x |
        TN(k) = tn;                                % | o x x |
        
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

    if len > 2 % correction for balanced accuracy multiclass case
       microAVG(19) = macroAVG(11); % BACC multiclass = macroaverage Recall
       macroAVG(19) = macroAVG(11); % BACC multiclass = macroaverage Recall
       wAVG(19) = macroAVG(11); % BACC multiclass = macroaverage Recall
    end
                 
    microAVG = microAVG(ID);
    macroAVG = macroAVG(ID);
    wAVG = wAVG(ID);

    %Names of the rows
    name = ["TP"; "FP"; "FN"; "TN"; ...
        "Accuracy"; "Precision"; "FDR"; "FOR"; "NPV"; ...
        "PRV"; "Recall"; "FPR"; "PLR"; "FNR"; "Specificity"; ...
        "NLR"; "DOR"; "IFM"; "MKD"; "F-score"; "G"; "MCC"; "BACC"];
    
    name = [name(1:4); name(4+ID)];

    %Names of the columns
    varNames = ["name"; "classes"; "macroAVG"; "microAVG"; "weightAVG"];

    %Values of the columns for each class
    values = [TP; FP; FN; TN; metrics(ID, :)];

    % All metrics: calculate also multi-class metrics MAvG and MAvA
    if nargin == 1 && len > 1
         name = [name; "MAvG"; "MAvA"];
         values = [values; zeros(1, len); zeros(1, len)];
         microAVG = [microAVG; 0; 0];
         wAVG = [wAVG; 0; 0];
 
         mavg = (prod(TP./(TP+FP))) ^ (1/len); % Macro average geometric 
         mava = (sum(TP./(TP+FP))) / len;      % Macro average arithmetic
         macroAVG = [macroAVG; mavg; mava];
    end
    
    %OUTPUT: final table
    stats = table(name, values, [0;0;0;0;macroAVG], [0;0;0;0;microAVG], ...
        [0;0;0;0;wAVG], 'VariableNames',varNames);
end

%--------------------------------------------------------------------------

%%
function [oneM]= compute(oneC, bt)

    if nargin == 1
        bt = 1;
    end

    TP = oneC(1,1);         % True positive
    FN = oneC(1,2);         % False negative
    TN = oneC(2,2);         % True negative
    FP = oneC(2,1);         % False positive
    P = TP+FN+TN+FP;        % total population
    OP = TP + FP;           % Output positive 
    ON = FN + TN;           % Output negative
    CP = TP + FN;           % Condition positive
    CN = FP + TN;           % Condition negative
    ACC = (TP + TN)/P;        % Accuracy
    PPV = TP/(OP+eps);        % Precision, positive predictive value
    FDR = FP/(OP+eps);        % False discovery rate
    FOR = FN/(ON+eps);        % False omission rate
    NPV = TN/(ON+eps);        % Negative predictive value
    PRV = CP/(P+eps);         % Prevalence
    TPR = TP/(CP+eps);        % Recall, true positive rate, sensitivity, hit rate
    FPR = FP/(CN+eps);        % False positive rate
    PLR = TPR/(FPR+eps);      % Positive likelihood ratio
    FNR = FN/(CP+eps);        % False negative rate
    TNR = TN/(CN+eps);        % True negative rate, specificity
    NLR = FNR/(TNR+eps);      % Negative likelihood ratio
    DOR = PLR/(NLR+eps);      % Diagnostic odds ratio
    IFM = TPR + TNR - 1;  % Informedness
    MKD = PPV + NPV - 1;  % Markedness
    Fbeta = (1 + bt^2)*PPV*TPR/(bt^2*(PPV + TPR+ eps)); % F-score
    G = sqrt(PPV*TPR); % G-measure
    MCC = (TP*TN - FP*FN)/(sqrt(OP*ON*CN*CP)+eps); % Matthews correlation coefficient
    BACC = ( (TP/(CP+eps)) + (TN/(CN+eps)) ) / 2; % Balanced accuracy
    oneM = [ACC,PPV,FDR,FOR,NPV,PRV,TPR,FPR,PLR,FNR,TNR,NLR,DOR,IFM,MKD,Fbeta,G,MCC,BACC]';     
end