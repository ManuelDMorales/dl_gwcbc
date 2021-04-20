function Data = Compute_CNNconstructXY(Data)

% Convertir Xtfr a X: the data format of X for the CNN should be (16 32 1 Nsamples)
for i=1:size(Data.Xtfr,1)
    Data.X(:,:,1,i) = squeeze(Data.Xtfr(i,:,:));
end
Data   = rmfield(Data,'Xtfr');

% Save currect Y and create the class label Y vector
YALL   = Data.Y;
Data   = rmfield(Data,'Y');

Data.Y      = YALL(:,1);
Data.YInfo  = YALL(:,2:end);
% Data.M1     = YALL(:,2);
% Data.M1     = YALL(:,3);
% Data.D      = YALL(:,4);
% Data.SNR    = YALL(:,5);

% Clear garbage
clear ans doplot IFO Nsamples IndRan IndTrai IndTest Nlabels IndRan i YALL