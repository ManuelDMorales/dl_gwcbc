function cfg = Compute_CNNcfg(Nsamples)



% ----------------------------------------
% 1) Initialize structure
% 
cfg                      = [];



% ----------------------------------------
% 2) Iteration and epochs: 
% 
% Recall that an iteration is one step taken in the gradient descent
% algorithm towards minimizing the loss function using a mini-batch. In
% other words, each iteration is an estimation of the gradient and an
% update of the network parameters
% 
cfg.MiniBatchSize        = 128;           % Subset of the training set that is used to evaluate the gradient of the loss function and update the weights 
cfg.MaxEpochs            = 100;           % An epoch is the full pass of the training algorithm over the entire training set
cfg.Shuffle              = 'once';        % (never|once|every-epoch) Shuffle the training data before each training epoch, and shuffle the validation data before each network validation



% ----------------------------------------
% 3) Validation process
% 
% A validation set is used to test learning and generalization during the
% training process.
% By default, if the validation loss is larger than or equal to the
% previously smallest loss five times in a row, then network training
% stops. To change the number of times that the validation loss is allowed
% to not decrease before training stops, use the 'ValidationPatience'. You
% can add additional stopping criteria using output functions
% 
cfg.ValidationData       = [];     % ({Xval,Yval}) Used to validate the network at regular intervals during training.
% cfg.ValidationFrequency  = 20;   % Number of iterations between evaluations of validation metrics. A suggestion is to choose this value so that the network is validated once/twice/.. per epoch.
cfg.NumValPerEpoch       = 1;      % Number of validations per epoch. This is not a "trainingOptions" parameter but it is used to gently compute the "ValidationFrequency"
cfg.ValidationFrequency  = floor(Nsamples/cfg.MiniBatchSize/cfg.NumValPerEpoch);
cfg.ValidationPatience   = 5;      % (scalar|Inf) Turn off the built-in validation stopping criterion (which uses the loss) by setting the 'ValidationPatience' value to Inf.
cfg.OutputFcn            = '@(info)stopIfAccuracyNotImproving(info,3));'; % The traininf calls the specified functions once before the start of training, after each iteration, and once after training has finished. The training passes a structure containing information in the following fields:
%cfg.OutputFcn            = '@(info)savetrainingplot(info);';

% ----------------------------------------
% 4) Learning rate 
% 
cfg.InitialLearnRate     = 1.01;        % (default:0.01) If the learning rate is too low, then training takes a long time. If the learning rate is too high, then training might reach a suboptimal result
cfg.LearnRateSchedule    = 'none';      % (none|piecewise) Option for dropping the learning rate during training. The software updates the learning rate every certain number of epochs by multiplying with a certain factor.
cfg.LearnRateDropFactor  = 0.1;         % (default:0.1)  Factor for dropping the learning rate. Multiplicative factor to apply to the learning rate every time a certain number of epochs passes. Valid only when the value of LearnRateSchedule is 'piecewise'.
cfg.LearnRateDropPeriod  = 4;           % (default:10)   Number of epochs for dropping the learning rate. Valid only when the value of LearnRateSchedule is 'piecewise'.



% ----------------------------------------
% Otros paramteres
% 
% cfg.CheckpointPath       =  % Path for saving checkpoint networks
% cfg.ExecutionEnvironment =  % (default:??????) (auto|cpu|gpu|multi-gpu|parallel) Hardware resource for training network
% cfg.L2Regularization     =  % (default:0.0001) Factor for L2 regularizer (weight decay). You can specify a multiplier for the L2 regularizer for network layers with learnable parameters.
% cfg.Momentum             =  % (default:0.9) Contribution of the gradient step from the previous iteration to the current iteration of the training. A value of 0 means no contribution from the previous step, whereas a value of 1 means maximal contribution from the previous step.



% ----------------------------------------
% Progress visualization
% 
cfg.Plots                  = 'none';      % (none|training-progress)
cfg.Verbose                = 1;                        % Indicator to display training progress information in the command window
cfg.VerboseFrequency       = cfg.ValidationFrequency;  % Frequency of verbose printing, which is the number of iterations between printing to the command window
