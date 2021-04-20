function [folds,foldsSVM,foldsNB] = Compute_ClassificationCrossValidation(X,Y,cfg)


%% INITIALIZE VARIABLES

% For CNN algorithm

folds.Nfolds         = cfg.Nfolds;

folds.Model          = cell(cfg.Nfolds,1);
folds.YTest          = cell(cfg.Nfolds,1);
folds.YEsti          = cell(cfg.Nfolds,1);
folds.YProb          = cell(cfg.Nfolds,1);
folds.YInfo          = cell(cfg.Nfolds,1);

folds.Metrics.CM     = zeros(2,2,cfg.Nfolds);
folds.Metrics.CA     = zeros(cfg.Nfolds,1);
folds.Metrics.F1     = zeros(cfg.Nfolds,1);
folds.Metrics.KP     = zeros(cfg.Nfolds,1);
folds.Metrics.Tclass = zeros(cfg.Nfolds,1);

% new included metrics
folds.Metrics.LL     = zeros(cfg.Nfolds,1);
folds.Metrics.PR     = zeros(cfg.Nfolds,1);
folds.Metrics.RE     = zeros(cfg.Nfolds,1);
folds.Metrics.FO     = zeros(cfg.Nfolds,1);

folds.All.YTest      = [];
folds.All.YEsti      = [];
folds.All.YProb      = [];
folds.All.Metrics    = cell(cfg.Nfolds,1);

% Additional arrays for SVM algorithm

foldsSVM.Nfolds         = cfg.Nfolds;

foldsSVM.Model          = cell(cfg.Nfolds,1);
foldsSVM.YEsti          = cell(cfg.Nfolds,1);
foldsSVM.YScore         = cell(cfg.Nfolds,1);

foldsSVM.Metrics.CM     = zeros(2,2,cfg.Nfolds);
foldsSVM.Metrics.CA     = zeros(cfg.Nfolds,1);
foldsSVM.Metrics.F1     = zeros(cfg.Nfolds,1);
foldsSVM.Metrics.KP     = zeros(cfg.Nfolds,1);
foldsSVM.Metrics.Tclass = zeros(cfg.Nfolds,1);

foldsSVM.Metrics.PR     = zeros(cfg.Nfolds,1);
foldsSVM.Metrics.RE     = zeros(cfg.Nfolds,1);
foldsSVM.Metrics.FO     = zeros(cfg.Nfolds,1);

foldsSVM.All.YEsti      = [];
foldsSVM.All.YScore     = [];
foldsSVM.All.Metrics    = cell(cfg.Nfolds,1);

% Additional arrays for NB algorithm
foldsNB.Nfolds          = cfg.Nfolds;

foldsNB.Model           = cell(cfg.Nfolds,1);
foldsNB.YEsti           = cell(cfg.Nfolds,1);
foldsNB.YProb           = cell(cfg.Nfolds,1);
foldsNB.Cost           = cell(cfg.Nfolds,1);

foldsNB.Metrics.CM     = zeros(2,2,cfg.Nfolds);
foldsNB.Metrics.CA     = zeros(cfg.Nfolds,1);
foldsNB.Metrics.F1     = zeros(cfg.Nfolds,1);
foldsNB.Metrics.KP     = zeros(cfg.Nfolds,1);
foldsNB.Metrics.Tclass = zeros(cfg.Nfolds,1);

foldsNB.Metrics.PR     = zeros(cfg.Nfolds,1);
foldsNB.Metrics.RE     = zeros(cfg.Nfolds,1);
foldsNB.Metrics.FO     = zeros(cfg.Nfolds,1);

foldsNB.All.YEsti      = [];
foldsNB.All.YProb      = [];
foldsNB.All.Cost      = [];
foldsNB.All.Metrics    = cell(cfg.Nfolds,1);

%% TRAINNING AND VALIDATION FOR EACH FOLD


for ifold = 1:cfg.Nfolds
    %ifold = 1; % solo para debugear mientras testeo algoritmos SVM y NB, comentar despues
    
    fprintf('Fold %i of %i \r',ifold,cfg.Nfolds)
    
    
    % --------------------------------------------
    % Indices of the train and test sets for the current fold
    Ind_test                     = (cfg.IndCroossVal == ifold);
    Ind_train                    = ~Ind_test;
    
    
    % --------------------------------------------
    % Get train trials for the current fold
    XTrain                       = X(:,:,:,Ind_train);
    YTrain                       = Y(Ind_train);
    
    
    % --------------------------------------------
    % Get test trials for the current fold
    XTest                        = X(:,:,:,Ind_test);
    YTest                        = Y(Ind_test);
    
    
    % --------------------------------------------
    % Train the CNN
    % disp(YTrain)
    % pause
    folds.Model{ifold}           = Compute_ClassificationTrain(XTrain,YTrain,cfg);
    % Salidas (nombres definidos dentro de la función): Model.net,Model.traininfo 
    
    % Train the SVM
    foldsSVM.Model{ifold}        = Compute_ClassificationTrainSVM(XTrain,YTrain,cfg);
    % Salida (nombre definido dentro de la función): SVMModel
    
    % Train the NB algorithm
    foldsNB.Model{ifold}        = Compute_ClassificationTrainNB(XTrain,YTrain,cfg);
    % Salida (nombre definido dentro de la función): NBModel 
    
    % --------------------------------------------
    % Classify the XTest data
    % With CNN algorithm
    tic
    [YEsti,YProb]                = Compute_ClassificationApply(XTest,folds.Model{ifold});
    folds.Metrics.Tclass(ifold)  = toc;
    
    % With SVM algorithm
    tic
    [YEstiSVM,YScoreSVM]            = Compute_ClassificationApplySVM(XTest,foldsSVM.Model{ifold});
    foldsSVM.Metrics.Tclass(ifold)  = toc;
    
    % With NB algorithm
    tic
    [YEstiNB,YProbNB,CostNB]       = Compute_ClassificationApplyNB(XTest,foldsNB.Model{ifold});
    foldsNB.Metrics.Tclass(ifold)  = toc;
    
    % --------------------------------------------
    % Save YTest, YEsti, YProb, YEstiSVM, and YScoreSVM for the current fold
    
    % CNN
    folds.YTest{ifold}          = YTest;
    folds.YEsti{ifold}          = YEsti;
    folds.YProb{ifold}          = YProb;
    
    % Additional data for SVM
    foldsSVM.YEsti{ifold}       = YEstiSVM;
    foldsSVM.YScore{ifold}      = YScoreSVM;
    
    % Additional data for NB
    foldsNB.YEsti{ifold}        = YEstiNB;
    foldsNB.YProb{ifold}        = YProbNB;
    foldsNB.Cost{ifold}         = CostNB;
    
    % --------------------------------------------
    % Compute metrics for the current fold
%     disp([YTest,YEsti])
%     disp(unique(YTest))
%     disp(unique(YEsti))

    % Metrics for CNN algorithm
    Metrics                      = Compute_ClassificationMetrics(YTest,YEsti,YProb);
    folds.Metrics.CM(:,:,ifold)  = Metrics.CM;
    folds.Metrics.CA(ifold)      = Metrics.CA;
    folds.Metrics.F1(ifold)      = Metrics.F1;
    folds.Metrics.KP(ifold)      = Metrics.KP;
    folds.Metrics.LL(ifold)      = Metrics.LL;
    % new included metrics
    folds.Metrics.PR(ifold)      = Metrics.PR;
    folds.Metrics.RE(ifold)      = Metrics.RE;
    folds.Metrics.FO(ifold)      = Metrics.FO;
    folds.Metrics.GM(ifold)      = Metrics.GM;

    % Metrics for SVM algorithm
    Metrics                         = Compute_ClassificationMetrics(YTest,YEstiSVM,YScoreSVM);
    foldsSVM.Metrics.CM(:,:,ifold)  = Metrics.CM;
    foldsSVM.Metrics.CA(ifold)      = Metrics.CA;
    foldsSVM.Metrics.F1(ifold)      = Metrics.F1;
    foldsSVM.Metrics.KP(ifold)      = Metrics.KP;
    foldsSVM.Metrics.PR(ifold)      = Metrics.PR;
    foldsSVM.Metrics.RE(ifold)      = Metrics.RE;
    foldsSVM.Metrics.FO(ifold)      = Metrics.FO;
    foldsSVM.Metrics.GM(ifold)      = Metrics.GM;
    
    % Metrics for NB algorithm
    Metrics                         = Compute_ClassificationMetrics(YTest,YEstiNB,YProbNB);
    foldsNB.Metrics.CM(:,:,ifold)  = Metrics.CM;
    foldsNB.Metrics.CA(ifold)      = Metrics.CA;
    foldsNB.Metrics.F1(ifold)      = Metrics.F1;
    foldsNB.Metrics.KP(ifold)      = Metrics.KP;
    foldsNB.Metrics.PR(ifold)      = Metrics.PR;
    foldsNB.Metrics.RE(ifold)      = Metrics.RE;
    foldsNB.Metrics.FO(ifold)      = Metrics.FO;
    foldsNB.Metrics.GM(ifold)      = Metrics.GM;
    
    % --------------------------------------------
    % Save YInfo for the current fold
    folds.YInfo{ifold}           = cfg.YInfo(Ind_test,:);
    
    
    % --------------------------------------------
    % Append YTest, YEsti, YProb across folds
    folds.All.YTest              = [ folds.All.YTest ; YTest ];
    folds.All.YEsti              = [ folds.All.YEsti ; YEsti ];
    folds.All.YProb              = [ folds.All.YProb ; YProb ];
    % for SVM algorithm
    foldsSVM.All.YEsti           = [ foldsSVM.All.YEsti ; YEstiSVM ];
    foldsSVM.All.YScore          = [ foldsSVM.All.YScore ; YScoreSVM ];
    % for NB algorithm
    foldsNB.All.YEsti           = [ foldsNB.All.YEsti ; YEstiNB ];
    foldsNB.All.YProb           = [ foldsNB.All.YProb ; YProbNB ];
    foldsNB.All.Cost            = [ foldsNB.All.Cost ; CostNB ];

    
    % create initial arrays for All SVM and NB results
    foldsSVM.All.Metrics    = cell(cfg.Nfolds,1);
    foldsNB.All.Metrics    = cell(cfg.Nfolds,1);
    
    
end % for ifold = 1:Nfolds


% --------------------------------------------
% Compute metrics across-all-folds

% CNN algorithm
folds.All.Metrics = Compute_ClassificationMetrics(folds.All.YTest,...
                    folds.All.YEsti,folds.All.YProb);

% SVM algorithm
foldsSVM.All.Metrics = Compute_ClassificationMetrics(folds.All.YTest,...
                       foldsSVM.All.YEsti,foldsSVM.All.YScore);

% NB algorithm
foldsNB.All.Metrics = Compute_ClassificationMetrics(folds.All.YTest,...
                      foldsNB.All.YEsti,foldsNB.All.YProb);

% --------------------------------------------
fprintf('PILAS: CNN accuracy of %3.2f%% \n',folds.All.Metrics.CA)

fprintf('PILAS: SVM accuracy of %3.2f%% \n',foldsSVM.All.Metrics.CA)

fprintf('PILAS: NB accuracy of %3.2f%% \n',foldsNB.All.Metrics.CA)