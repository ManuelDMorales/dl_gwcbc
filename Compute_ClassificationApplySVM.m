function [YEstiSVM, YScoreSVM] = Compute_ClassificationApplySVM(XTest,Model)



%% APPLY CLASSIFIER: APPLY MODEL TO NEW DATA

% Size of input data
Sx = size(XTest,1);
Sy = size(XTest,2);
Sz = size(XTest,3);
Sn = size(XTest,4);

% i) flat images in XTrain, ii) remove dimension of length 1, iii) transpose
XTest_flat = transpose(squeeze(reshape(XTest,[Sx*Sy,Sz,Sn])));

% Apply classifier. Get predicted class and the probability for each class
[YEstiSVM,YScoreSVM] = predict(Model.SVMModel,XTest_flat);


% Convert predictec class from categorical to double
if iscategorical(YEstiSVM)
    YEstiSVM = grp2idx(YEstiSVM);
end

% Convert cell array to double array
YEstiSVM = str2num(cell2mat(YEstiSVM));