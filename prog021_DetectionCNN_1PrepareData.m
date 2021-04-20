% ==================================
% Get data segments with injection and noise
% ==================================

% Written by Dr. Manuel David Morales and Dr. Javier M. Antelis
% Any questions? manueld.morales@academicos.udg.mx

%% INITIALIZE

% ----------------------------------------
% Comment the next three lines when the "Meta Program" is executed
clearvars
close all
clc

% ----------------------------------------
% Select RUN, IFO, file and Twin
RUN      = 'S6';  % (S5|S6) % RUN
IFO        = 'L1';  % (H1|L1) % Interferometer

% Comment the next two lines just when the "Meta Program" is executed
ifile      = 160;     % hdf5 file (1:722) for H1, (1:652) for L1
Twin     = 0.25;   % (0.25|0.50|1.00|1.50|2.00|...) % Window's width



%% LOAD DATA AND GET THE SEGMENT OF 128S CONTANING AN INJECTION

% Load ligo data
% last index 0: no plot, 1: plot
ligo              = gw_readligo(RUN,IFO,ifile,0);

% Get a 128s-long data segment
data              = gw_computegetdata(ligo,0);

% Save path and filename
data.path         = ligo.path;
data.filename     = ligo.filename;

% Clear garbage
clear ans ligo



%% VERIFY THAT ALL THE DATA IS OK

% Check if the strain data in the segment contain NaN values
if isnan(sum(data.st))
    % The strain data in the segment contain NaN values
    save([data.path 'FileStrainWithNaN_' num2str(ifile)],'ifile')
    fprintf('data contains NaN')
else
    % Do nothing, all strain data in the segment in OK
    
end % if isnan(sum(data.st))



%% ARREGLAR "TIME", "TIMEGPS" AND "TIME INJECTION"

% Create "timegps" vector en unidades de gps
data.timegps       = data.t;

% Create "t" vector en unidades de seconds
data.t             = data.t                - data.timegps(1);

% Calculat el tcoal inyectado en unidades de seconds
data.injection.t   = data.injection.GPS    - data.timegps(1);



%% WHITENING AND BAND PASS FILTERING OF THE STRAIN DATA

% Apply whitening and band pass filterig
datawhitened              = gw_computewhitendata(data,8,[20 1000],16,0);
% Cantidad entre [ ] define el filtro

% Save injection informarion in the "datawhitened" variable
datawhitened.injection    = data.injection;

% Adjust tcoal (as the whitening rejected a section of data)
if (1)
    % Adjust the tcoal inyectado en unidades de seconds para la TW actual
    datawhitened.injection.t  = datawhitened.injection.t - datawhitened.TW2reject;
else
    % Recover the eliminated TW2reject in the time vector
    % datawhitened.t            =  datawhitened.t + datawhitened.TW2reject;
end

% Save path and filename
datawhitened.path         = data.path;
datawhitened.filename     = data.filename;

% Plot for debugging
if (0)
    figure, clf
    
    subplot(3,1,1), hold on
    plot(data.t,data.st,'b'), hold on
    %if ligo.injection.PNorder==2
    %    plot(template.t+data.injection.t-template.t(end),1*template.st,'r')
    %end
    line([data.injection.t data.injection.t],[-1.2*max(abs(data.st)) 1.2*max(abs(data.st))],'Color',[1 0 0])
    xlabel('Time (s)'), ylabel('s(t)'), title(['Data segment ' '']), box on,
    set(gca,'Xlim',[data.t(1) data.t(end)]), set(gca,'Ylim',[-1.2*max(abs(data.st)) 1.2*max(abs(data.st))]), %set(gca,'Ylim',[-1e-15 1e-15])
    title(['Injection at t=' num2str(data.injection.t)])
    
    subplot(3,1,2), hold on
    plot(datawhitened.t+datawhitened.TW2reject,datawhitened.st,'b'), hold on
    %if ligo.injection.PNorder==2
    %    plot(template.t+datawhitened.injection.t-template.t(end)+0.06,2*template.st,'r')
    %end
    line([datawhitened.injection.t datawhitened.injection.t]+datawhitened.TW2reject,[-1.2*max(abs(data.st)) 1.2*max(abs(data.st))],'Color',[1 0 0])
    xlabel('Time (s)'), ylabel('s(t)'), title(['Data segment ' '']), box on,
    title(['Injection at t=' num2str(data.injection.t)])
    set(gca,'Xlim',[data.t(1) data.t(end)]),
    set(gca,'Ylim',[-1.2*max(abs(datawhitened.st)) 1.2*max(abs(datawhitened.st))]), %set(gca,'Ylim',[-1e-15 1e-15])
    
    subplot(3,1,3), hold on
    plot(datawhitened.t+0*datawhitened.TW2reject,datawhitened.st,'b'), hold on
    %if ligo.injection.PNorder==2
    %    plot(template.t+datawhitened.injection.t-template.t(end)+0.06,2*template.st,'r')
    %end
    line([datawhitened.injection.t datawhitened.injection.t]+0*datawhitened.TW2reject,[-1.2*max(abs(data.st)) 1.2*max(abs(data.st))],'Color',[1 0 0])
    xlabel('Time (s)'), ylabel('s(t)'), title(['Data segment ' '']), box on,
    title(['Injection at t=' num2str(datawhitened.injection.t)])
    set(gca,'Xlim',[data.t(1) data.t(end)]),
    set(gca,'Ylim',[-1.2*max(abs(datawhitened.st)) 1.2*max(abs(datawhitened.st))]), %set(gca,'Ylim',[-1e-15 1e-15])
    
    return
    
end % if (0)

% Clear garbage
clear ans data



%% COMPUTE SEGMENT INFORMATION

% Get segments info
Segments = gw_getsegmentsinfoOVERLAP(round(datawhitened.t(end)-datawhitened.t(1)),Twin,3*Twin/4,4096);

% Identify the two/four/X (if Tove=50/75/X%) consecutive segments with the injection
Segments.InIn   = and(Segments.Tint(:,1)<datawhitened.injection.t,Segments.Tint(:,2)>=datawhitened.injection.t);

% Stop if there is no segments with injection
if sum(Segments.InIn)==0
    error('PILAS: No hay injeccion en ninguno de los segmentos')
elseif sum(Segments.InIn)==4 % (2s:Tove=50% | 4s:Tove=75%)
    % do nothing
else
    error('PILAS: El numero de segmentos con injeccion no es correcto')
end
clear ans Sini Send Tend Tini



%% DEBUGING: Plot strain and wavelet for each segment (time resolved)

if (0)
    
    inicio = find(Segments.InIn);
    inicio = inicio(1)-5;
    for i=inicio:Segments.Nseg
        
        % Get data segments
        datasegment          = datawhitened.st(Segments.Sint(i,1):Segments.Sint(i,2));
        t                    = datawhitened.t(Segments.Sint(i,1):Segments.Sint(i,2));
        
        % Normalize strain
        datasegment          = 1e20 * datasegment;
        
        % Compute time-frequency representation based on Morlet wavelet
        [tfr,aja,ftfr]       = Compute_WaveletMorlet(datasegment,datawhitened.fs,1,500,10,7,1);
        
        
        % Plot for debugging
        if (0)
            figure(12), clf
            
            subplot(3,1,1)
            area(Segments.Tint(i,:)+0*datawhitened.t(1),[2 2],'BaseValue',-2,'FaceColor',[0.93 0.93 0.93],'LineStyle','none'), hold on
            plot(datawhitened.t,1e20 *datawhitened.st,'b','LineWidth',1), hold on
            line([datawhitened.injection.t datawhitened.injection.t],[-2 2],'Color',[1 0 0])
            set(gca,'XLim',[datawhitened.t(1) datawhitened.t(end)]),
            set(gca,'YLim',[-1 1]),
            xlabel('Time (s)'), ylabel('Strain')
            title('Whitened and band-pass filtered strain data')
            grid on, box on
            
            subplot(3,1,2)
            plot(t,datasegment,'b','LineWidth',1), hold on
            set(gca,'XLim',[t(1) t(end)]),
            set(gca,'YLim',[-1 1]),
            xlabel('Time (s)'), ylabel('Strain')
            title('Current time window')
            grid on, box on
            
            subplot(3,1,3)
            mesh(t,ftfr,tfr)
            xlabel('Time (s)'), ylabel('Frequency (Hz)')
            title('h(t,f)')
            colormap jet, view(0,90)
            box on, grid on
            set(gca,'XLim',[t(1) t(end)]),
            set(gca,'Ylim',[min(ftfr) max(ftfr)])
            
            drawnow
            
            if Segments.InIn(i)==1
            	title('GW SIGNAL IS PRESENT')
                pause
            end % if Segments.InIn(i)==1
            
        end % if (1)
        
    end % for i=1:Segments.Nseg
    clear ans i inicio
    
    return
    
end % if (doplot)



%% COMPUTE AND CONSTRUCT THE STRAIN-BASED FEATURES

% Get ID de los segmentos a usar
if (0)
    % Option 1: uno con injection y uno con noise
    SEGinjec = find(Segments.InIn);     % ID de todos los segmentos con injection
    SEGinjec = SEGinjec(2);             % ID del segmento con injection con el que nos quedamos
    SEGnoise = SEGinjec-3;              % ID del segmento con ruido
else
    % Option 2: Todos los que tengan injection y el mismo numero con noise
    if sum(Segments.InIn)==2
        SEGinjec = find(Segments.InIn);             % ID de los dos segmentos con injection
        SEGnoise = [SEGinjec(1)-3; SEGinjec(2)+3];  % ID de los dos segmentos con ruido
    elseif sum(Segments.InIn)==4
        SEGinjec = find(Segments.InIn);                                               % ID de los cuatro segmentos con injection
        SEGnoise = [SEGinjec(1)-4; SEGinjec(1)-3; SEGinjec(end)+3; SEGinjec(end)+4];  % ID de los cuatro segmentos con ruido
    else
        error('PILAS PERRO: trabaje')
    end %
end % if (0)


% Be sure that the number of segments with injection and with noise is the same
if length(SEGnoise)~=length(SEGinjec)
    error('PILAS: the number of segments with injection/noise is not the same')
end % if length(SEGnoise)~=length(SEGinjec)


% Get data, i.e., segments with injection and segments with noise
DataInjec = zeros(Twin*4096,length(SEGinjec));
DataNoise = zeros(Twin*4096,length(SEGnoise));
for i=1:length(SEGnoise)
    % Segments with injection
    IDseg          = SEGinjec(i);
    DataInjec(:,i) = datawhitened.st(Segments.Sint(IDseg,1):Segments.Sint(IDseg,2));
    
    % Segments with noise
    IDseg          = SEGnoise(i);
    DataNoise(:,i) = datawhitened.st(Segments.Sint(IDseg,1):Segments.Sint(IDseg,2));
end % for i=1:length(SEGnoise)
clear ans i IDseg


% Clear garbage
clear ans SEGinjec SEGnoise Segments


% Debugging: compute and plot TFR
if (0)
    
    % Number of segments with injection and noise
    Nsegments = size(DataInjec,2);
    
    % Time vector
    t = (0:1:size(DataNoise,1)-1)/4096;
    
    % For each segment with injection and noise
    for i=1:Nsegments
        
        % Compute TFR
        [DataInjec1_tfr,  ~,   ~]  = Compute_WaveletMorlet(1e20*DataInjec(:,i),datawhitened.fs,20,400,10,7,0);
        [DataNoise1_tfr,aja,ftfr]  = Compute_WaveletMorlet(1e20*DataNoise(:,i),datawhitened.fs,20,400,10,7,0);

        % Plot for debugging
        figure(1)
        subplot(2,Nsegments,i)
        plot(t,1e20*DataInjec(:,i))
        subplot(2,Nsegments,i+Nsegments)
        mesh(t,ftfr,DataInjec1_tfr)
        xlabel('Time (s)'), %ylabel('Frequency (Hz)'), % title('h(t,f)'), colormap jet, 
        view(0,90), box on, grid on
        set(gca,'XLim',[t(1) t(end)]), set(gca,'Ylim',[min(ftfr) max(ftfr)])
        
        figure(2)
        subplot(2,Nsegments,i)
        plot(t,1e20*DataNoise(:,i))
        subplot(2,Nsegments,i+Nsegments)
        mesh(t,ftfr,DataNoise1_tfr)
        xlabel('Time (s)'), %ylabel('Frequency (Hz)'), % title('h(t,f)'), colormap jet, 
        view(0,90), box on, grid on
        set(gca,'XLim',[t(1) t(end)]), set(gca,'Ylim',[min(ftfr) max(ftfr)])
        
    end % for i=1:Nsegments
    clear ans i Nsegments t aja ftfr DataInjec1_tfr DataNoise1_tfr
    
end % if (0)


% Number of segments with injection and noise
Nsegments = size(DataInjec,2);


% Contruct X and y
X   = [DataNoise  DataInjec];

y   = [1*ones(Nsegments,1) ; 2*ones(Nsegments,1)];
M1  = [NaN(Nsegments,1) ; datawhitened.injection.M1*ones(Nsegments,1)];
M2  = [NaN(Nsegments,1) ; datawhitened.injection.M2*ones(Nsegments,1)];
D   = [NaN(Nsegments,1) ; datawhitened.injection.D*ones(Nsegments,1)];
SNR = [NaN(Nsegments,1) ; datawhitened.injection.Exp_SNR*ones(Nsegments,1)];

Y   = [y M1 M2 D SNR];


% Contruct Data structure with only the important info
Data.Twin        = Twin;
Data.fs          = datawhitened.fs;
Data.Xstrain     = X;
Data.Y           = Y;


% Part of the name to save data
if     Twin==0.25, TwinStr='025';    
elseif Twin==0.50, TwinStr='050';
elseif Twin==0.75, TwinStr='075';
elseif Twin==1.00, TwinStr='100';
elseif Twin==1.25, TwinStr='125';
elseif Twin==1.50, TwinStr='150';
elseif Twin==1.75, TwinStr='175';
elseif Twin==2.00, TwinStr='200';
else,  error('PILAS: unknown Tslice')
end
% Save only if the strain data do not contain NaN values
if isnan(sum([sum(DataInjec(:)) sum(DataNoise(:))])) % isnan(sum(datawhitened.st))
    % The strain data in the segment contain NaN values
    save([datawhitened.path 'FileTFRWithNaN_' num2str(ifile)],'ifile')
else
    % OK: save data
    save([datawhitened.path datawhitened.filename(1:end-5) '_Twin' TwinStr],'Data')
end % if isnan(sum(data.st))


% Clear garbage
%clear ans y M1 M2 D SNR X Y Log DataNoise1 DataNoise2 DataInjec1 DataInjec2 
%clear ans DataNoise DataInjec TwinStr Nsegments datawhitened Data



%% PERFORM ANALYSIS FOR ALL EXISTING FILES

% Keep this "if" always in 0 and comment lines 3 to 11
if (0)
    % Initialize
    clearvars
    close all
    clc
    
    RUN        = 'S6';
    IFOS       = {'L1'}; % {'H1','L1'};
    
    Twin       = 1.5; % (0.25|0.50|1.00|1.50|2.00|...)
    
    for ii=1:length(IFOS)
        
        IFO = IFOS{ii};
        
        % List of existing datafiles
        if strcmp(IFO,'H1')
            % THE FILE IS NOT AVAILABLE IN LOSC FOR DOWNLOAD: 59,60,61,206:212,657:676 (para evitar errores en el codigo, cree un fake archivo)
            % TOO EARLY OR TOO LATE INJECTION: 73,106,145,224,244,313,688
            datafiles = 1:724;
            datafiles([59,60,61,206:212,657:676,73,106,145,224,244,313,688]) = [ ];
        elseif strcmp(IFO,'L1')
            % THE FILE IS NOT AVAILABLE IN LOSC FOR DOWNLOAD: 59,60,147:150,566  (para evitar errores en el codigo, cree un fake archivo)
            % TOO EARLY OR TOO LATE INJECTION: 118,134,235,264,375,415
            datafiles = 1:656;
            datafiles([59,60,147:150,566,118,134,235,264,375,415]) = [ ];
        end
        
        % Perform detection for each datafile
        for ifile=datafiles
            fprintf('\nProcessing datafile %d of %d\n',ifile,max(datafiles))
            prog021_DetectionCNN_1PrepareData
            clear ans data datawhitened Data Segments
        end
        clear ans ifile datafiles
        
    end % for ii=1:length(IFOS)
    clear ans ii Twin
    
end % if(0)
