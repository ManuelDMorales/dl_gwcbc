function [YEsti, YProb] = Compute_ClassificationApply(XTest,Model)



%% APPLY CLASSIFIER: APPLY MODEL TO NEW DATA

% Apply classifier. Get predicted class and the probability for each class
[YEsti,YProb] = classify(Model.net,XTest);

% Convert predictec class from categorical to double
if iscategorical(YEsti)
    YEsti = grp2idx(YEsti);
end