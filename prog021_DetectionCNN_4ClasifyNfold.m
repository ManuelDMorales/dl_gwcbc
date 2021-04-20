% ==================================================
% Classification: N-fold cross validation for train and test the CNN
% ==================================================

% Written by Dr. Manuel David Morales and Dr. Javier M. Antelis
% Any questions? manueld.morales@academicos.udg.mx
    
%% A) INITIALIZE

% ----------------------------------------
clearvars
close all
clc

% ---- For repeating the analysis

Nruns = 10; % Nruns = 1, 5, 10, 20, 40, 80

for ifile = 1:Nruns
    % just for new tests and debug
    % ifile = 1;
NrunsStr = num2str(Nruns);
ifileStr = num2str(ifile);

% ----------------------------------------
% Select IFO anbd Twin
IFO        = 'L1';    % (H1|L1|BOTH)
Twin       = '075';   % (025|050|075|100|125|150|175|200)


%% B) LOAD DATA

% ----------------------------------------
% Load data
if strcmp(IFO,'H1')||strcmp(IFO,'L1')
    % Load data for the H1 or L1
    RutaData       = ['/home/claudia/Codes Manuel/Datasets/Data2016_LIGOS6/' IFO '/'];
    load([RutaData 'TFR-TW' Twin])
elseif strcmp(IFO,'BOTH')
    % Load data for H1
    RutaData       = ['/home/claudia/Codes Manuel/Datasets/Data2016_LIGOS6/' 'H1' '/'];
    H1             = load([RutaData 'TFR-TW' Twin]);
    % Load data for L1
    RutaData       = ['/home/claudia/Codes Manuel/Datasets/Data2016_LIGOS6/' 'L1' '/'];
    L1             = load([RutaData 'TFR-TW' Twin]);
    % Save path
    RutaData       = ['/home/claudia/Codes Manuel/Datasets/Data2016_LIGOS6/' 'BOTH' '/'];
    % Append data
    Data           = H1.Data;
    Data.Y         = [H1.Data.Y    ; L1.Data.Y   ];
    Data.Xtfr      = [H1.Data.Xtfr ; L1.Data.Xtfr];
    % Clear garbage
    clear ans H1 L1
else
    error('PILAS: unknown IFO')
end

% ----------------------------------------
% Remove unused fields
Data.IFO       = IFO;
Data.RutaData  = RutaData;

% ----------------------------------------
% Remove unused fields
Data           = rmfield(Data,'t');
Data           = rmfield(Data,'f');

% ----------------------------------------
% Clear garbage
clear ans TwinStr Twin RutaData H1 L1 % IFO



%% C) CONSTRUCT X AND Y

% Make sure that the class labels are 1 and 2
Data = Compute_CheckLabels(Data);

% Eliminate data for which SNR<10 (eliminate the same samples for both class)
Data = Compute_CNNeliminateSNR(Data,10);

% Construct X and Y
% 1) Convert from Xtfr to X in the data format for the CNN
% 2) Save the current Y matrix as YInfo and create the class label vector Y
Data = Compute_CNNconstructXY(Data);



%% D) CLASSIFICATION 1: N-FOLD CROSS VALIDATION


% % Fix random number generator seed
% rng(2)


% Configuration del N-fold
cfg                = [];
cfg.Nfolds         = 10;
NfoldsStr          = num2str(cfg.Nfolds);
cfg.IndCroossVal   = crossvalind('Kfold',size(Data.X,4),cfg.Nfolds); %load('IndCroossVal'), cfg.IndCroossVal   = IndCroossVal;
cfg.Shuffling      = 'YES';

% Configuracion de la CNN
cfg.Nstacks        = 2;  % Maximo 3
cfg.Nfilters       = 16; % 8, 12, 16, 20, 24, 28, 32

% Save important info
cfg.YInfo          = Data.YInfo;

% solo para debugear mientras testeo algoritmos SVM y NB, comentar despues
%X = Data.X;
%Y = Data.Y;

% Perform Nfold-fold cross-validation
[Folds,FoldsSVM,FoldsNB]   = Compute_ClassificationCrossValidation(Data.X,Data.Y,cfg);

% Remove unwanted fields
cfg                = rmfield(cfg,'YInfo');



%% SAVE DATA


% Save results
if     Data.Twin==0.25, TwinStr='025';
elseif Data.Twin==0.50, TwinStr='050';
elseif Data.Twin==0.75, TwinStr='075';
elseif Data.Twin==1.00, TwinStr='100';
elseif Data.Twin==1.25, TwinStr='125';
elseif Data.Twin==1.50, TwinStr='150';
elseif Data.Twin==1.75, TwinStr='175';
elseif Data.Twin==2.00, TwinStr='200';
else,  Data.error('PILAS: unknown Tslice')
end

save([Data.RutaData 'CNN-TW' TwinStr '-S' num2str(cfg.Nstacks) 'F' num2str(cfg.Nfilters) '-' cfg.Shuffling '-Nfolds' NfoldsStr '-Nruns' NrunsStr '-irun' ifileStr],'Data','Folds','FoldsSVM','FoldsNB','cfg')

end


