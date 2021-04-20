% =======================================================================
% Meta Program: For repeatedly running program prog021_DetectionCNN_1PrepareData.m
% =======================================================================

% Written by Dr. Manuel David Morales and Dr. Javier M. Antelis
% Any questions? manueld.morales@academicos.udg.mx

%% RUN prog021_DetectionCNN_1PrepareData.m for each ifile

% Vary ifile and get data segments with injection and noise

% 722 files for Data2016_LIGOS6 H1 was used
% 652 files for Data2016_LIGOS6 L1 was used

for ifile = 1:652
    fprintf('\nProcessing hdf5 file num. %d \n',ifile)
    
    Twin = 0.25;
    try
        run prog021_DetectionCNN_1PrepareData;
    catch
    end
    
    for Twin = 0.50:0.25:2.00
        try
            run prog021_DetectionCNN_1PrepareData;
        catch
        end
    end
end