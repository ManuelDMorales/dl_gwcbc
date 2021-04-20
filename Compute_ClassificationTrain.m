function Model = Compute_ClassificationTrain(XTrain,YTrain,cfg)



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

% Define model options: 'Plots','training-progress'
cfgOptions    = Compute_CNNcfg(Nsamples);

Model.options = trainingOptions('sgdm',...
    'MaxEpochs',cfgOptions.MaxEpochs,...
    'MiniBatchSize',cfgOptions.MiniBatchSize,...
    'Shuffle',cfgOptions.Shuffle,... 
    'ValidationData',{XValid,categorical(YValid)},...
    'ValidationFrequency',cfgOptions.ValidationFrequency,...
    'ValidationPatience',cfgOptions.ValidationPatience,...
    'Plots',cfgOptions.Plots,...
    'Verbose',cfgOptions.Verbose,...
    'VerboseFrequency',cfgOptions.ValidationFrequency...
    );    
%'OutputFcn',cfgOptions.OutputFcn...

% Size of the input map
Sx = size(XTrain,1);
Sy = size(XTrain,2);
Sz = size(XTrain,3);

%disp(Sx)
%disp(Sy)
%disp(Sz)

% Define model arquitecture
if cfg.Nstacks==1
    
    % CNN arquitecture (PILAS: manually fix the dimension of the input layer)
    Model.layers = [ ...
        imageInputLayer([Sx Sy Sz],'Name','INPUT')
        
        %convolution2dLayer([5 5],cfg.Nfilters,'Name','CONV1')
        convolution2dLayer([4 5],cfg.Nfilters,'Name','CONV1')
        
        reluLayer('Name','RELU1')
        maxPooling2dLayer(2,'Stride',2,'Name','MAXPOOL1')
        
        fullyConnectedLayer(2,'Name','FULL')
        softmaxLayer('Name','SOFTMAX')
        classificationLayer('Name','OUTPUT')];
    
elseif cfg.Nstacks==2
    
    % CNN arquitecture (PILAS: manually fix the dimension of the input layer)
    Model.layers = [ ...
        imageInputLayer([Sx Sy Sz],'Name','INPUT')
        
        %convolution2dLayer([5 5],cfg.Nfilters(1),'Name','CONV1')
        convolution2dLayer([4 5],cfg.Nfilters(1),'Name','CONV1')
        reluLayer('Name','RELU1')
        maxPooling2dLayer(2,'Stride',2,'Name','MAXPOOL1')
        
        %convolution2dLayer([5 5],cfg.Nfilters(1),'Name','CONV2')
        convolution2dLayer([4 5],cfg.Nfilters(1),'Name','CONV2')
        reluLayer('Name','RELU2')
        maxPooling2dLayer(2,'Stride',2,'Name','MAXPOOL2')
        
        fullyConnectedLayer(2,'Name','FULL')
        softmaxLayer('Name','SOFTMAX')
        classificationLayer('Name','OUTPUT')];
    
elseif cfg.Nstacks==3
    
    % CNN arquitecture (PILAS: manually fix the dimension of the input layer)
    Model.layers = [ ...
        imageInputLayer([Sx Sy Sz],'Name','INPUT')
        
        %convolution2dLayer([5 5],cfg.Nfilters(1),'Name','CONV1')
        convolution2dLayer([4 5],cfg.Nfilters(1),'Name','CONV1')
        reluLayer('Name','RELU1')
        maxPooling2dLayer(2,'Stride',2,'Name','MAXPOOL1')
        
        %convolution2dLayer([5 5],cfg.Nfilters(1),'Name','CONV2')
        convolution2dLayer([4 5],cfg.Nfilters(1),'Name','CONV2')
        reluLayer('Name','RELU2')
        maxPooling2dLayer(2,'Stride',2,'Name','MAXPOOL2')
        
        %convolution2dLayer([1 2],cfg.Nfilters(1),'Name','CONV3')
        convolution2dLayer([1 4],cfg.Nfilters(1),'Name','CONV3')
        reluLayer('Name','RELU3')
        %maxPooling2dLayer(1,'Stride',1,'Name','MAXPOOL3')
        maxPooling2dLayer([1 2],'Stride',1,'Name','MAXPOOL3')
        
        fullyConnectedLayer(2,'Name','FULL')
        softmaxLayer('Name','SOFTMAX')
        classificationLayer('Name','OUTPUT')];
    
else
    error('PILAS: trabaje perro')

end

% Train classifier: compute the model
tic
[Model.net,Model.traininfo] = trainNetwork(XTrain,categorical(YTrain),Model.layers,Model.options);
Model.Ttrain = toc;

%  function plotTrainingLoss(info)
%  persistent plotObj
%  info.State == "start"
%  plotObj = animatedline('Color','r');
%     xlabel("Iteration")
%     ylabel("Loss")
%     title("Training loss evolution")
%  elseif info.State == "iteration"
%     %addpoints(plotObj,info.Iteration,info.TrainingLoss)
%     addpoints(plotObj, info.Iteration, gather(double(info.TrainingLoss)))
%     drawnow limitrate nocallbacks
%     fprintf('%d \n',info.TrainingLoss)
%  end