%GETMAPPING restituisce una struttura contenente una tabella di mapping per i codici LBP.
%  MAPPING = GETMAPPING(SAMPLES,MAPPINGTYPE) restituisce una 
%  struttura contenente una tabella di mapping per i codici LBP in una 
%  zona di SAMPLES punti di campionamento. I possibili valori per MAPPINGTYPE sono
%       'u2'   per LBP uniforme
%       'ri'   per LBP invarianti alla rotazione
%       'riu2' per LBP uniforme e invarianti alla rotazione.
%
%  Esempio:
%       I=imread('rice.tif');
%       MAPPING=getmapping(16,'riu2');
%       LBPHIST=lbp(I,2,16,MAPPING,'hist');
%  Ora LBPHIST contiene un istogramma LBP uniforme e invarianti alla rotazione
%  in una zona di (16,2).
%

function mapping = getmapping(samples,mappingtype)

table = 0:2^samples-1;
newMax  = 0; % numero di pattern nel codice LBP risultante
index   = 0;

if strcmp(mappingtype,'u2') % Uniforme 2
  newMax = samples*(samples-1) + 3; 
  for i = 0:2^samples-1
      
    j = bitset(bitshift(i,1),1,bitget(i,samples)); % ruota a sinistra
    numt = sum(bitget(bitxor(i,j),1:samples)); % numero di transizioni 1->0 e
                                               % 0->1 nella stringa binaria 
                                               % x è uguale al numero di bit 1 in
                                               % XOR(x, Ruota sinistra(x)) 
    if numt <= 2
      table(i+1) = index;
      index = index + 1;
    else
      table(i+1) = newMax - 1;
    end
  end
end

if strcmp(mappingtype,'ri') % Invarianti alla rotazione
  tmpMap = zeros(2^samples,1) - 1;
  for i = 0:2^samples-1
    rm = i;
    r  = i;
    for j = 1:samples-1
      r = bitset(bitshift(r,1),1,bitget(r,samples)); % ruota a sinistra
      if r < rm
        rm = r;
      end
    end
    if tmpMap(rm+1) < 0
      tmpMap(rm+1) = newMax;
      newMax = newMax + 1;
    end
    table(i+1) = tmpMap(rm+1);
  end
end

if strcmp(mappingtype,'riu2') % Uniforme e Invarianti alla rotazione
  newMax = samples + 2;
  for i = 0:2^samples - 1
    j = bitset(bitshift(i,1),1,bitget(i,samples)); % ruota a sinistra
    numt = sum(bitget(bitxor(i,j),1:samples));
    if numt <= 2
      table(i+1) = sum(bitget(i,1:samples));
    else
      table(i+1) = samples+1;
    end
  end
end

mapping.table=table;
mapping.samples=samples;
mapping.num=newMax;