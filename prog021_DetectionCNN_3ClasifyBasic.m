% ==============================================
% Basic classification: Train/Test a single CNN as sanity check
% ==============================================

% Written by Dr. Manuel David Morales and Dr. Javier M. Antelis
% Any questions? manueld.morales@academicos.udg.mx

%% A) INITIALIZE
% ##### Parameters to manually set: IFO, TWIN

% ----------------------------------------
clearvars
close all
clc

% ----------------------------------------
% Select IFO (interferometer) anb Twin (old detector)
% H1: Hanford detector | L1: Livingstone detector
IFO        = 'H1';    % (H1|L1|BOTH)
Twin      = '050';   % (025|050|100|150|200)


%% B) LOAD DATA

% ----------------------------------------
% Load data
% Remark: Dots (.) define structure arrays
% Fields of Data.Y: class (0 OR 1); M1, M2 (mass in solar masses),
%                   distance (Mpc), and SNR (signal-to-noise ratio).

if strcmp(IFO,'H1')||strcmp(IFO,'L1')
    % Load data for the H1 or L1
    RutaData       = ['/home/manuel/Projects Science/Data analysis/Datasets/Data2017_LIGOS6/' IFO '/'];
    %RutaData       = ['C:\_DataSets\Data2017_LIGOS6\' IFO '\'];
    load([RutaData 'TFR-TW' Twin])
elseif strcmp(IFO,'BOTH')
    % Load data for H1
    RutaData       = ['/home/manuel/Projects Science/Data analysis/Datasets/Data2017_LIGOS6/' 'H1' '/'];
    H1             = load([RutaData 'TFR-TW' Twin]);
    % Load data for L1
    RutaData       = ['/home/manuel/Projects Science/Data analysis/Datasets/Data2017_LIGOS6/' 'L1' '/'];
    L1             = load([RutaData 'TFR-TW' Twin]);
    % Save path
    RutaData       = ['/home/manuel/Projects Science/Data analysis/Datasets/Data2017_LIGOS6/' 'BOTH' '/'];
    % Append data
    Data           = H1.Data;
    Data.Y         = [H1.Data.Y    ; L1.Data.Y   ];
    Data.Xtfr      = [H1.Data.Xtfr ; L1.Data.Xtfr];
    
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
clear ans TwinStr Twin IFO RutaData



%% C) CONSTRUCT X AND Y
% ##### Parameters to manually set: pointer "S" in the module
%                                   Compute_CNNeliminateSNR(Data,S);

% Here external functions are called
% Class 1: NOISE, Class 2: Gravitational Waves
% Make sure that the class labels are 1 and 2
Data = Compute_CheckLabels(Data);

% Eliminate data for which SNR<10 (eliminate the same samples for both class)
Data = Compute_CNNeliminateSNR(Data,10);

% Construct X and Y
% 1) Convert from Xtfr to X in the data format for the CNN [images]
% 2) Save the current Y matrix as YInfo and create the class label vector Y
Data = Compute_CNNconstructXY(Data);



%% D) CLASSIFICATION 0: TRAIN AND TEST A SINGLE CNN TO CHECK IF ALL IS WORKING

% ----------------------------------------
% 0) Initialize variable
CNN              = [];
CNN.layers       = [];
CNN.options      = [];
CNN.net          = [];
CNN.traininfo    = [];

CNN.XTrain       = [];
CNN.YTrain       = [];

CNN.XValid       = [];
CNN.YValid       = [];

CNN.XTest        = [];
CNN.YTest        = [];

CNN.YEsti        = [];
CNN.YProb        = [];
CNN.ACC          = [];
CNN.CM           = [];


% ----------------------------------------
% 1) Separate dataset into two mutually exclusive sets: (1) train and (2) test
% ##### Parameters to manually set: float f (0<f<1) in Nsamples*f
%                                   [default option: f=0.9]

Nsamples         = size(Data.X,4);
IndRan           = randperm(Nsamples);
IndTra           = IndRan(1:round(Nsamples*.9));
IndTes           = IndRan(round(Nsamples*.9)+1:end);

CNN.XTrain       = Data.X(:,:,:,IndTra);
CNN.YTrain       = Data.Y(IndTra,1);

CNN.XTest        = Data.X(:,:,:,IndTes);
CNN.YTest        = Data.Y(IndTes,1);

clear ans IndTra IndTes IndRan Nsamples


% ----------------------------------------
% 2) Separate train set into two sets: (1) train and (2) validation
% ##### Parameters to manually set: float f (0<f<1) in Nsamples*f
%                                   [default option: f=0.9]

Nsamples         = size(CNN.XTrain,4);
IndRan           = randperm(Nsamples);
IndTra           = IndRan(1:round(Nsamples*.9));
IndVal           = IndRan(round(Nsamples*.9)+1:end);

CNN.XValid       = CNN.XTrain(:,:,:,IndVal);
CNN.YValid       = CNN.YTrain(IndVal,1);

CNN.XTrain       = CNN.XTrain(:,:,:,IndTra);
CNN.YTrain       = CNN.YTrain(IndTra,1);

clear ans IndTra IndVal IndRan Nsamples


% ----------------------------------------
% 3) Design CNN: arquitecture
CNN.layers       = [ ...
    imageInputLayer([16 32 1],'Name','INPUT')

%   **** Feature Extraction Network
    convolution2dLayer([5 5],20,'Name','CONV1')
    reluLayer('Name','RELU1')
    maxPooling2dLayer(2,'Stride',2,'Name','MAXPOOL1')

%   **** Classifier Network
    fullyConnectedLayer(2,'Name','FULL')
    softmaxLayer('Name','SOFTMAX')
    classificationLayer('Name','OUTPUT')];


% ----------------------------------------
% 4) Define trainning options
% ##### Parameters to manually set inside Compute_CNNcfg

cfg = Compute_CNNcfg(size(CNN.XTrain,4));

CNN.options = trainingOptions('sgdm',...
    'MaxEpochs',cfg.MaxEpochs,...
    'MiniBatchSize',cfg.MiniBatchSize,...
    'Shuffle',cfg.Shuffle,...
    'ValidationFrequency',cfg.ValidationFrequency,...
    'ValidationPatience',cfg.ValidationPatience,...
    'Plots',cfg.Plots,...
    'Verbose',cfg.Verbose,...
    'VerboseFrequency',cfg.ValidationFrequency...
    );
% Other training options
%     'ValidationData',{CNN.XValid,categorical(CNN.YValid)},...
%     'InitialLearnRate',cfg.InitialLearnRate,...
%     'LearnRateSchedule','piecewise',...
%     'LearnRateDropFactor',cfg.LearnRateDropFactor,...
%     'LearnRateDropPeriod',cfg.LearnRateDropPeriod,...

%%

% ----------------------------------------
% 6) Train classifier
[CNN.net,CNN.traininfo] = trainNetwork(CNN.XTrain,categorical(CNN.YTrain),CNN.layers,CNN.options);


% ----------------------------------------
% 7) Test classifier
[CNN.YEsti, CNN.YProb]  = classify(CNN.net,CNN.XTest);


% ----------------------------------------
% 8) Compute metrics
CNN.Metrics             = Compute_ClassificationMetrics(CNN.YTest,CNN.YEsti);


% ----------------------------------------
% 9) Plot training metrics
% x_train = 1:length(CNN.traininfo.TrainingLoss);
%
% x_valid = 1:length(CNN.traininfo.ValidationLoss);
% Ind2Eli = isnan(CNN.traininfo.ValidationLoss);
% x_valid(Ind2Eli) = [];
% CNN.traininfo.ValidationLoss(Ind2Eli) = [];
%
% figure(1), clf
%
% subplot(2,1,1), hold on
% plot(x_train,CNN.traininfo.TrainingLoss)
% plot(x_valid,CNN.traininfo.ValidationLoss)
% legend('Train','Valid')
%
% subplot(2,1,2), hold on
% plot(CNN.traininfo.TrainingAccuracy)
% plot(CNN.traininfo.ValidationAccuracy)
% legend('Train','Valid')