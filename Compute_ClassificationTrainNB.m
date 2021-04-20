function Model = Compute_ClassificationTrainNB(XTrain,YTrain,cfg)



%% SHUFFLING

if ~isfield(cfg,'Shuffling')
    % do nothing
else
    if strcmp(cfg.Shuffling,'YES')
        IndRandom  = randperm(length(YTrain));
        YTrain     = YTrain(IndRandom);
    else
        % do nothing
    end % if strcmp(cfg.Shuffling,'YES')
end % if isfield((cfg,'Shuffling')



%% TRAIN CLASSIFIER: COMPUTE MODEL

% % Fix random number generator seed
% rng(2)

% Separate train set into two sets: (1) train set and (2) validation set
Nsamples      = size(XTrain,4);
IndRan        = randperm(Nsamples);
IndVal        = IndRan(1:round(Nsamples*.1));
IndTra        = IndRan(round(Nsamples*.1)+1:end);

XValid        = XTrain(:,:,:,IndVal);
YValid        = YTrain(IndVal,1);

XTrain        = XTrain(:,:,:,IndTra);
YTrain        = YTrain(IndTra,1);

% Indices de XTrain:
% 1 y 2 -> Dimensiones de la imagen en pixeles
% 3 -> Canal (para todos es igual a 1)
% 4 -> Etiqueta para contar imágenes

% Size of input data
Sx = size(XTrain,1);
Sy = size(XTrain,2);
Sz = size(XTrain,3);
Sn = size(XTrain,4);

% i) flat images in XTrain, ii) remove dimension of length 1, iii) transpose
XTrain_flat = transpose(squeeze(reshape(XTrain,[Sx*Sy,Sz,Sn])));

tic
Model.NBModel = fitcnb(XTrain_flat,categorical(YTrain),...
                      'ClassNames',{'1','2'});
Model.Ttrain = toc;