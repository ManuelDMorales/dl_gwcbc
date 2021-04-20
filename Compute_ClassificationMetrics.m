function Metrics = Compute_ClassificationMetrics(YTest,YEsti,YProb)

   fprintf('num. de clases en YTest: %d\n', length(unique(YTest)))
   fprintf('num. de clases en YEsti: %d\n', length(unique(YEsti)))

% --------------------------------------------
% verificar que ambos vectores tengan el mismo numero de clases
%if length(unique(YTest)) ~= length(unique(YEsti))
%    error('PILAS: no hay el mismo numero de clases')
%end

% --------------------------------------------
% Convertir de categorical a double
if iscategorical(YTest)
    YTest = grp2idx(YTest);
end
if iscategorical(YEsti)
    YEsti = grp2idx(YEsti);
end


% --------------------------------------------
% Verificar que ambos vectores tengan el mismo nombre para las clases i.e. 1,2,3
% error('PILAS: los nombres de las clases son diferentes entre YTest y YEsti')


% --------------------------------------------
currentlabels  = unique(YTest);
Nclasses       = length(currentlabels);
if Nclasses==2    
    classes = [1 2];
    confu   = zeros(2,2);
elseif Nclasses==3
    classes = [1 2 3];
    confu   = zeros(3,3);
else
    error('PILAS: trabaje perro')
end
clear ans currentlabels


% --------------------------------------------
% Compute classification accuracy
% acc = 100*sum((YTest-YEsti)==0)/length(YTest); PILAS BORRAR
acc = 100*sum(YEsti == YTest) / numel(YTest);

% --------------------------------------------
% Compute confusion matrix [YTest YEsti]
if Nclasses==2
    Ind_Class1 = (YTest==classes(1));
    Ind_Class2 = (YTest==classes(2));
    
    confu(1,1) = sum(YEsti(Ind_Class1)==1);
    confu(1,2) = sum(YEsti(Ind_Class1)==2);
    confu(1,:) = 100*confu(1,:)/sum(Ind_Class1);
    
    confu(2,1) = sum(YEsti(Ind_Class2)==1);
    confu(2,2) = sum(YEsti(Ind_Class2)==2);
    confu(2,:) = 100*confu(2,:)/sum(Ind_Class2);
    
    % esto posiblemente esta mal
    tp         = 100*confu(1,1);
    fp         = 100*confu(1,2);
    fn         = 100*confu(2,1);
    tn         = 100*confu(2,2);
    f1score    = 2 *  tp ./ (2 * tp + fp + fn);
    
    kappa      = (acc-50)/(100-50);

    % new metrics included
    
    precision = tp / (tp + fp) ;
    recall = tp / (tp + fn) ;
    fallout = fp / (fp + tn) ;
    
    % last metric included: gmean1=sqrt(recall*fallout)
    gmean1 = sqrt(recall*fallout) ;
    
elseif Nclasses==3
    Ind_Class1 = (YTest==classes(1));
    Ind_Class2 = (YTest==classes(2));
    Ind_Class3 = (YTest==classes(3));
    
    confu(1,1) = sum(YEsti(Ind_Class1)==1);
    confu(1,2) = sum(YEsti(Ind_Class1)==2);
    confu(1,3) = sum(YEsti(Ind_Class1)==3);
    confu(1,:) = 100*confu(1,:)/sum(Ind_Class1);
    
    confu(2,1) = sum(YEsti(Ind_Class2)==1);
    confu(2,2) = sum(YEsti(Ind_Class2)==2);
    confu(2,3) = sum(YEsti(Ind_Class2)==3);
    confu(2,:) = 100*confu(2,:)/sum(Ind_Class2);
    
    confu(3,1) = sum(YEsti(Ind_Class3)==1);
    confu(3,2) = sum(YEsti(Ind_Class3)==2);
    confu(3,3) = sum(YEsti(Ind_Class3)==3);
    confu(3,:) = 100*confu(3,:)/sum(Ind_Class3);
    
    f1score    = NaN;
    
    kappa      = (acc-(100/3))/(100-(100/3));
    
end

% --------------------------------------------
% Compute the log-loss
if any(YProb(:)<0)
    log_loss = 0;
else
    log_loss = -1*sum(log(YProb(1))) + sum(log(YProb(2)));
end

% Save results
Metrics.CA   = acc;
Metrics.CM   = confu;
Metrics.F1   = f1score;
Metrics.KP   = kappa;
Metrics.LL   = log_loss;

Metrics.PR   = precision;
Metrics.RE   = recall;
Metrics.FO   = fallout;

Metrics.GM   = gmean1;