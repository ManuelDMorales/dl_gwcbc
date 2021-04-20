function ligo = gw_readligo(RUN,IFO,Ni,doplot)
% close all; clear all; clc; doplot = 1; Ni=1; IFO='H1'; RUN='S5';




%% GET INJECTION INFORMATION

% Load injection data and filename con the Ni-th file
if     strcmp(RUN,'S5')
    ligo.injection     = gw_getinjectioninfoS5(IFO,Ni);
    ligo.path          = '/media/manuel/ADATA HD710 PRO/Files CUVALLES/Codes Manuel CUVALLES/Datasets/Data2016_LIGOS6/';
    ligo.filename      = ligo.injection.filename;
    
elseif strcmp(RUN,'S6')
    ligo.injection     = gw_getinjectioninfoS6(IFO,Ni);
    ligo.path          = ['/media/manuel/ADATA HD710 PRO/Files CUVALLES/Codes Manuel CUVALLES/Datasets/Data2016_LIGOS6/' IFO '/'];
    ligo.filename      = ligo.injection.filename;
    
    
    
    % ****************************
    % GW150914
elseif strcmp(RUN,'GW150914_32')
    ligo.path          = 'C:\_DataSets\GW150914\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V2-1126259446-32.hdf5'];
    
elseif strcmp(RUN,'GW150914_4096')
    ligo.path          = 'C:\_DataSets\GW150914\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V1-1126257414-4096.hdf5'];    
    
    
        
    % ****************************
    % LVT151012
elseif strcmp(RUN,'LVT151012_32')
    ligo.path          = 'C:\_DataSets\LVT151012\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V2-1128678884-32.hdf5'];
elseif strcmp(RUN,'LVT151012_4096')
    ligo.path          = 'C:\_DataSets\LVT151012\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V2-1128676852-4096.hdf5'];
    
    
    
    % ****************************
    % GW151226
elseif strcmp(RUN,'GW151226_32')
    ligo.path          = 'C:\_DataSets\GW151226\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V2-1135136334-32.hdf5'];
    
elseif strcmp(RUN,'GW151226_4096')
    ligo.path          = 'C:\_DataSets\GW151226\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V2-1135136228-4096.hdf5'];
    
    
    
    % ****************************
    % GW170104
elseif strcmp(RUN,'GW170104_32')
    ligo.path          = 'C:\_DataSets\GW170104\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V1-1167559920-32.hdf5'];
    
elseif strcmp(RUN,'GW170104_4096')
    ligo.path          = 'C:\_DataSets\GW170104\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_4_V1-1167557888-4096.hdf5'];
    
    
    
    % ****************************
    % GW170608
elseif strcmp(RUN,'GW170608_32')
    ligo.path          = 'C:\_DataSets\GW170608\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_C01_4_V1-1180922478-32.hdf5'];
    
elseif strcmp(RUN,'GW170608_4096')
    ligo.path          = 'C:\_DataSets\GW170608\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_C01_4_V1-1180920446-4096.hdf5'];
    
    
    
    % ****************************
    % GW170814
elseif strcmp(RUN,'GW170814_32')
    ligo.path          = 'C:\_DataSets\GW170814\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_CLN_4_V1-1186741845-32.hdf5'];
elseif strcmp(RUN,'GW170814_4096')
    ligo.path          = 'C:\_DataSets\GW170814\';
    %ligo.filename      = [IFO(1) '-' IFO '_LOSC_C00_4_V1-1186739813-4096.hdf5'];
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_CLN_4_V1-1186740069-3584.hdf5'];
    
    
    
    % ****************************
    % GW170817
elseif strcmp(RUN,'GW170817_32')
    error('PILAS: This LIGO data is not available')
elseif strcmp(RUN,'GW170817_4096')
    ligo.path          = 'C:\_DataSets\GW170817\';
    ligo.filename      = [IFO(1) '-' IFO '_LOSC_C00_4_V1-1187006834-4096.hdf5'];    
    
    
    
    % ****************************
    % LIGO O1 
elseif strcmp(RUN,'O1')
    % Get the path of the O1 LIGO data 
    ligo.path          = ['D:\_DataSets\' 'LIGOO1' '\'];
    
    % Get the filename of all existing HDF5 files
    AllFilenames       = dir([ligo.path IFO(1:1) '-' IFO '_LOSC_4_V1-*-4096.hdf5']);
    
    % Save the current filename
    ligo.filename      = AllFilenames(Ni).name;
    
    
    
    % ****************************
    % LIGO O1 WITH INJECTIONS
elseif strcmp(RUN(1:6),'LIGOO1')
    
    ligo.injection     = gw_getinjectioninfoO1CBC(RUN,IFO);
    ligo.path          = ['D:\_DataSets\' RUN(1:6) '\']; % PC TEC
    %ligo.path          = ['/Users/gravwaves/Documents/_DataSets/' RUN(1:6) '/']; % MAC PERSONAL
    ligo.filename      = ligo.injection.filename;

    
    
    % ****************************
else
    error('PILAS: Unknown LIGO data')
    
end



%% LOAD DATA

% Visualize info from the file
%h5disp([path filename])

% Sampling frequency and period
% [ligo.path ligo.filename]
ligo.ts                   = hdf5read([ligo.path ligo.filename],'/strain/Strain','Xspacing'); % delta t
ligo.fs                   = 1/ligo.ts;   % frecuencia
ligo.Npoints              = double(hdf5read([ligo.path ligo.filename],'/strain/Strain','Npoints')); % j (posicion en el tiempo)
ligo.Tblock               = ligo.Npoints/ligo.fs; % periodo

% Get the start and end time of the data
ligo.gpsini               = double(hdf5read([ligo.path ligo.filename],'/strain/Strain','Xstart'));
ligo.gpsend               = ligo.gpsini + ligo.Tblock-1*ligo.ts;

% Read the strain values
ligo.strain               = hdf5read([ligo.path ligo.filename],'/strain/Strain');
ligo.timegps              = linspace(ligo.gpsini,ligo.gpsend,length(ligo.strain))';
ligo.timesec              = ligo.timegps - ligo.timegps(1);

% Plot strain data
if (doplot)
    if  isfield(ligo,'injection')
        %     % GRAFICA PARA PAPER/PRESENTACION
        %     figure, clf, set(gcf,'Position',[19 336 1227 289])
        %     plot(ligo.timegps,ligo.strain,'k','LineWidth',1), hold on
        %     line([ligo.injection.GPS ligo.injection.GPS],[-1e-10 1e-10],'Color',[1 0 0])
        %     %xlabel('Time (gps)'), ylabel('strain'), title(['Start=' num2str(ligo.timegps(1)) ' | ' 'End=' num2str(ligo.timegps(end))  ' | ' 'Coal=' num2str(ligo.injection.GPS)])
        %     set(gca,'Xlim',[ligo.timegps(1) ligo.timegps(end)],'Ylim',[-1.5e-16 1.5e-16]),
        %     set(gca,'XTickLabel',[ ],'YTickLabel',[]),
        
        %     OTRA GRAFICA
        figure(1), clf
        subplot(2,1,1), hold on
        plot(ligo.timegps,ligo.strain), line([ligo.injection.GPS ligo.injection.GPS],[-1e-10 1e-10],'Color',[1 0 0])
        xlabel('Time (gps)'), ylabel('strain'), title(['Start=' num2str(ligo.timegps(1)) ' | ' 'End=' num2str(ligo.timegps(end))  ' | ' 'Coal=' num2str(ligo.injection.GPS)])
        set(gca,'Xlim',[ligo.timegps(1) ligo.timegps(end)],'Ylim',[-1e-15 1e-15]), box on
        subplot(2,1,2), hold on
        plot(ligo.timesec,ligo.strain), line([ligo.injection.GPS ligo.injection.GPS]-ligo.gpsini,[-1e-10 1e-10],'Color',[1 0 0])
        xlabel('Time (s)'), ylabel('strain'), title(['Start=' num2str(ligo.timesec(1)) ' | ' 'End=' num2str(ligo.timesec(end))  ' | ' 'Coal=' num2str(ligo.injection.GPS-ligo.gpsini)])
        set(gca,'Xlim',[ligo.timesec(1) ligo.timesec(end)],'Ylim',[-1e-15 1e-15]), box on
    else
        %         figure(1), clf
        %
        %         subplot(2,1,1), hold on
        %         plot(ligo.timegps,ligo.strain,'b'),
        %         xlabel('Time (gps)'), ylabel('strain'), title(['Start=' num2str(ligo.timegps(1)) ' | ' 'End=' num2str(ligo.timegps(end)) ])
        %         set(gca,'Xlim',[ligo.timegps(1) ligo.timegps(end)])
        %         %set(gca,'Ylim',[-1e-18 1e-18]),
        %         box on
        %
        %         subplot(2,1,2), hold on
        %         plot(ligo.timesec,ligo.strain,'b'),
        %         xlabel('Time (s)'), ylabel('strain'), title(['Start=' num2str(ligo.timesec(1)) ' | ' 'End=' num2str(ligo.timesec(end)) ])
        %         set(gca,'Xlim',[ligo.timesec(1) ligo.timesec(end)])
        %         %set(gca,'Ylim',[-1e-18 1e-18]),
        %         box on
        
        figure
        
        % Strain data
        subplot(2,1,1), hold on
        plot(ligo.timesec,ligo.strain,'b'),
        xlabel('Time (s)'), ylabel('Strain (unitless)'), title('s(t): strain signal')
        set(gca,'Xlim',[ligo.timesec(1) ligo.timesec(end)])
        %set(gca,'Ylim',[-1e-18 1e-18]),
        box on
        
        % Amplitude Spectral Density
        PSD = gw_computePSD(ligo,1,0);
        
        
        subplot(2,1,2), hold on
        plot(PSD.fpsd,PSD.asd,'b','LineWidth',1)
        plot(PSD.fpsd,PSD.asdref,'k','LineWidth',1)
        xlabel('Frequency (Hz)'), ylabel('ASD (Hz^{-1/2})')
        title('ASD(f): amplitude spectral density')
        set(gca,'XScale','Log','YScale','Log')
        set(gca,'XLim',[10 ligo.fs/2]), set(gca,'YLim',[1e-24 1e-19])
        grid on, box on       
        
    end % if  ~isempty(ligo.injection)
end % if (1)



%% COMPUTE SEGMENTS INFORMATION (VALID FOR S5 AND S6)

if  isfield(ligo,'injection')
    % Duration of the data segment and overlap (seconds)
    ligo.segments.Twin        = 128;           % even and power of two
    ligo.segments.Tove        = ligo.segments.Twin/2;
    
    % Number of segments
    ligo.segments.Nseg        = 2*(ligo.Tblock/ligo.segments.Twin)-1;
    
    % % Debugging: Compute Tblock
    % Tblock   = ((ligo.segments.Nseg-1)*(ligo.segments.Tove*ligo.fs)+ligo.segments.Twin*ligo.fs)*ligo.ts
    
    % Time ini and Time end of each segment (seconds)
    Tini                      = (1:ligo.segments.Tove:ligo.Tblock-ligo.segments.Tove)';
    Tend                      = Tini+ligo.segments.Twin-1;
    
    % Sample ini and Sample end of each segment (sample)
    Sini                      = (Tini-1)*ligo.fs+1;
    Send                      = (Tend-0)*ligo.fs+0;
    
    % Time and samples of each interval
    ligo.segments.Tint        = [Tini Tend];
    ligo.segments.Sint        = [Sini Send];
    
    % Get segment where the GW was injected
    tcoal                     = ligo.injection.GPS - ligo.gpsini;
    d                         = ligo.segments.Tint - tcoal;
    md                        = abs(d(:,1)+d(:,2));
    [~, ligo.segments.seginj] = min(md);
    
else
    % do nothing
    
end % if isfield(ligo,'injection')



%% INITIALIZE OTHER THINGS (VALID FOR S5 AND S6)

if  isfield(ligo,'injection')
    ligo.NFFT                 = ligo.segments.Twin * ligo.fs;
    ligo.injection.fs         = ligo.fs;
    ligo.injection.NFFT       = ligo.NFFT;
    
else
    % do nothing
    
end % if  isfield(ligo,'injection')



%% VERIFICAR QUE EL GPS INJETION ESTE DENTRO DEL GPS DE LOS DATOS LEIDOS

if  isfield(ligo,'injection')
    if ligo.injection.GPS-ligo.gpsini>0 && ligo.gpsend-ligo.injection.GPS>0
        % Todo bien
        fprintf('FINO: The strain data contains an injection\n')
    else
        ligo %#ok<NOPRT>
        ligo.injection
        error('PILAS: GPSinjection is outside GPSdata')
    end % if ligo.injection.GPS-ligo.gpsini>0 && ligo.gpsend-ligo.injection.GPS>0
    
else
    % do nothing
    
end % if isfield(ligo,'injection')



%% CHECK WHETHER THE INJECTION WAS SUCESSFULL (VALID FOR S5 AND S6)

if  isfield(ligo,'injection')
    if strcmp(ligo.injection.Log,'Injection-Compromised') || strcmp(ligo.injection.Log,'Did-not-execute')
        error('PILAS: Injection compromised. Not posible to evaluate CBC hardware injection')
    else
        % Injection was sucesfull
        
    end % if strcmp(ligo.injection.Log,'Injection-Compromised') || strcmp(ligo.injection.Log,'Did-not-execute')
    
else
    % do nothing
    
end % if isfield(ligo,'injection')



