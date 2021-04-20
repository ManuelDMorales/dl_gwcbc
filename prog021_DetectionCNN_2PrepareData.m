% ============================================
% Compute Time-Frequency maps  for each data segment
% ============================================

% Written by Dr. Manuel David Morales and Dr. Javier M. Antelis
% Any questions? manueld.morales@academicos.udg.mx

%% INITIALIZE

% ----------------------------------------
clearvars 
close all
clc

% ----------------------------------------
% Select IFO and get existing filenames
IFO              = 'L1';    % (H1|L1)
Twin            = '100';   % (025|050|100|150|200) besides 075, 125, 175
RutaData    = ['/home/claudia/Codes Manuel/Datasets/Data2016_LIGOS6/' IFO '/'];
filenames   = dir([RutaData '*_Twin' Twin '.mat']);



%% COMPUTE AND CONSTRUCT THE TFR-BASED FEATURES FOR ALL EXISTING FILES


% ----------------------------------------
% Initialize variables
DataAll.Twin      = [];
DataAll.Xtfr      = [];
DataAll.Y         = [];


% ----------------------------------------
% For each existing file:
for i=1:length(filenames)
    %i=1; %just for debug, remember restablish the loop for when debug ends
    fprintf('Processing file number %d of %d\n',i,length(filenames))
    
    % ----------------------------------------
    % Load data
    load([RutaData filenames(i).name])
    
    % ----------------------------------------
    % Compute TFR
    for idata = 1:size(Data.Xstrain,2)
        
        %fprintf('Processing %d of %d\n',idata,size(Data.Xstrain,2))
        
        % Compute TFR
        [TFR,timeVec,freqVec]    = Compute_WaveletMorlet(1e20*Data.Xstrain(:,idata),Data.fs,40,500,10,7,0);
        
        % Compute reduced TFR
        TFRreduced               = imresize(TFR,[16,32]);
        
        % Save reduced TFR
        Data.Xtfr(idata,:,:)     = TFRreduced;
        Data.time                = linspace(min(timeVec),max(timeVec),size(TFRreduced,2));
        Data.freq                = linspace(min(freqVec),max(freqVec),size(TFRreduced,1));
        
        % Plot for debugging
        % PLOT OF SAMPLES (time length = Twin): NOISE ALONE, and NOISE+GW
        if (1)
            
            time1            = timeVec;
            freq1            = freqVec;
            time2            = linspace(min(time1),max(time1),size(TFRreduced,2));
            freq2            = linspace(min(freq1),max(freq1),size(TFRreduced,1));
            
            figure(1), clf
            
            subplot(3,1,1)
            plot(time1,Data.Xstrain(:,idata))
            
            condit = double(isnan(Data.Y(idata,2)));
            
            if (condit)
                title(['Noise Only'], 'FontSize',11)    
            else
                title(['M1=' num2str(Data.Y(idata,2)) '  |  M2=' num2str(Data.Y(idata,3)) '  | D=' num2str(Data.Y(idata,4)) '  |  SNR=' num2str(Data.Y(idata,5))], 'FontSize',11)
            end
            
            subplot(3,1,2)
            imagesc(time1,freq1,TFR)
            xlabel('Time (s)'), ylabel('Frequency (Hz)'),
            colormap jet, view(0,90), box on, grid on, set(gca,'YDir','normal')
            set(gca,'XLim',[time1(1) time1(end)]), set(gca,'Ylim',[min(freq1) max(freq1)])
            
            subplot(3,1,3)
            imagesc(time2,freq2,TFRreduced)
            xlabel('Time (s)'), ylabel('Frequency (Hz)'),
            colormap jet, view(0,90), box on, grid on, set(gca,'YDir','normal')
            set(gca,'XLim',[time2(1) time2(end)]), set(gca,'Ylim',[min(freq2) max(freq2)])
            pause
            clear ans time1 time2 freq1 freq2
        end % if (0)
        clear ans TFR TFRreduced
        
        %pause % just for debug....comment for normal run
    
    end % for idata = 1:size(DataAll.X,1)
    clear ans idata
    
    % ----------------------------------------
    % Append data
    DataAll.Xtfr  = [ DataAll.Xtfr ; Data.Xtfr];
    DataAll.Y     = [ DataAll.Y    ; Data.Y   ];
    
end % for i=1:length(filenames)
clear ans i filenames


% ----------------------------------------
% Save Twin and sampling frequency
%Data.Twin         = Twin
DataAll.Twin      = Data.Twin;
DataAll.t         = Data.time;
DataAll.f         = Data.freq;


% ----------------------------------------
% Clear garbage
clear ans TFR TFRreduced Data


% ----------------------------------------
% Data to save
Data     = DataAll;


% ----------------------------------------
% Save data
if     Data.Twin==0.25, TwinStr='025';
elseif Data.Twin==0.50, TwinStr='050';
elseif Data.Twin==0.75, TwinStr='075';
elseif Data.Twin==1.00, TwinStr='100';
elseif Data.Twin==1.25, TwinStr='125';
elseif Data.Twin==1.50, TwinStr='150';
elseif Data.Twin==1.75, TwinStr='175';
elseif Data.Twin==2.00, TwinStr='200';
else,  error('PILAS: unknown Tslice')
end
save([RutaData 'TFR-TW' TwinStr],'Data')


% ----------------------------------------
% Clear garbage
clear ans IFO DataAll
