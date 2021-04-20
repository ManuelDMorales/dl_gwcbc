function injection = gw_getinjectioninfoS6(INTERFEROMETER,Ni)
% close all; clear all; clc; Ni=2; INTERFEROMETER='H1';
% 
% PILAS: se asume que el Ni injection information coincide con el Ni
% datafile contenido en el folder Data_LIGOS6


%%% Read injection information

% GPS time of the end of the injection, or the "merger" time, in GPS seconds
% Mass, in solar units, of each compact object 
% Distance to the simulated source in Mpc
% Expected SNR of the injection
% Recovered SNR of the injection
% SNRs from 1-5 are typical for times with no signal.

m       = csvread([INTERFEROMETER '_s6cbc_simple.txt'],1,0); % Data obtained from https://www.gw-openscience.org/s6hwcbc/
GPS     = m(Ni,1); 
M1      = m(Ni,2);
M2      = m(Ni,3); 
D       = m(Ni,4); 
Exp_SNR = m(Ni,5); 
Rec_SNR = m(Ni,6);

%%% New section for burst injections

% GPS_burst, time of the injection
% hrss, amplitude of the burst (root-sum-squared)
% waveform-freq-q-tau-bandwidth:
% -- waveform, name of the waveform
% -- freq, frequency
% -- q, quality factor (tau*f0)
% -- tau, 

%n         = csvread([INTERFEROMETER '_s6burst_simple'],1,0); % Data obtained from https://www.gw-openscience.org/s6hwburst/
%GPS_burst = n(Ni,1); 
%hrss      = n(Ni,2);
%waveform  = textscan ...n(Ni,3); 
%D         = n(Ni,4); 
%Exp_SNR   = n(Ni,5); 
%Rec_SNR   = n(Ni,6);



% Get filenames
if     strcmp(INTERFEROMETER,'H1')
    hdf5Files   = dir(['/media/manuel/ADATA HD710 PRO/Files CUVALLES/Codes Manuel CUVALLES/Datasets/Data2016_LIGOS6/' INTERFEROMETER '/H-' INTERFEROMETER '*.hdf5']);
    %['C:\_DataSets\Data2017_LIGOS6\' INTERFEROMETER '\H-' INTERFEROMETER '*.hdf5']
elseif strcmp(INTERFEROMETER,'L1')
    hdf5Files   = dir(['/media/manuel/ADATA HD710 PRO/Files CUVALLES/Codes Manuel CUVALLES/Datasets/Data2016_LIGOS6/' INTERFEROMETER '/L-' INTERFEROMETER '*.hdf5']);
end

% hdf5Files

% Save injection info
injection.GPS      = GPS;
injection.IFO      = INTERFEROMETER;
injection.M1       = M1;
injection.M2       = M2;
injection.D        = D;
injection.Log      = []; % que es esto??
injection.Exp_SNR  = Exp_SNR;
injection.Rec_SNR  = Rec_SNR;
injection.filename = hdf5Files(Ni).name;

injection.PNorder  = 3.5; % que es esto?


%% PLOT INJECTION INFO

if (0)
    
    % Limpiar workspace
    clear all; close all; clc
    
    RUN = 'S6'; % (S5|S6|O1CBC)
    IFO = 'L1'; % (L1|H1)
    
    % Load data
    if strcmp(RUN,'S5')
        % Read data
        [~,~,M1,M2,D,LOG,~,~] = textread([IFO '_cleanlog_cbc.txt'],'%d %s %f %f %f %s %f %f'); % que es este archivo?
        
        % Compute total mass
        M     = M1 + M2;
        
        %         % Eliminar si D==0
        %         M1(D==0) = [];
        %         M2(D==0) = [];
        %         M(D==0)  = [];
        %         D(D==0)  = [];
        
        % Eliminar si D==0 or if injection is marked as not 'Successful'
        Ind2Eli     = or((~strcmp(LOG,'Successful')),(D==0)); % Number of discharged files: sum(Ind2Eli)
        M1(Ind2Eli) = [];
        M2(Ind2Eli) = [];
        M(Ind2Eli)  = [];
        D(Ind2Eli)  = [];
        
        fprintf([RUN ' - ' IFO '\r'])
        fprintf('Total number of data blocks with injections: %d \r',length(Ind2Eli))
        fprintf('Discharged data blocks (unsuccessful or missinf info): %d \r',sum(Ind2Eli))
        fprintf('Numer of used data blocks: %d \r',length(Ind2Eli)-sum(Ind2Eli))

        % Contruct data for m1=m2=1.4
        ind   = and(M1==1.4,M2==1.4);
        M1_14 = M1(ind); M1_14 = M1_14 + linspace(-0.75,0.75,length((M1_14)))'; M1_14 = M1_14(randperm(length(M1_14)));
        M2_14 = M2(ind); M2_14 = M2_14 + linspace(-0.75,0.75,length((M2_14)))';
        D_14  = D(ind);
        M_14  = M(ind);
        
        % Contruct data for m1=m2=3.0
        ind   = and(M1==3.0,M2==3.0);
        M1_03 = M1(ind); M1_03 = M1_03 + linspace(-0.75,0.75,length((M1_03)))'; M1_03 = M1_03(randperm(length(M1_03)));
        M2_03 = M2(ind); M2_03 = M2_03 + linspace(-0.75,0.75,length((M2_03)))';
        D_03  = D(ind);
        M_03  = M(ind);
        
        % Contruct data for m1=m2=10
        ind   = and(M1==10,M2==10);
        M1_10 = M1(ind); M1_10 = M1_10 + linspace(-0.75,0.75,length((M1_10)))'; M1_10 = M1_10(randperm(length(M1_10)));
        M2_10 = M2(ind); M2_10 = M2_10 + linspace(-0.75,0.75,length((M2_10)))';
        D_10  = D(ind);
        M_10  = M(ind);
        
        %         % Contruct data for m1=1.12||m2=5.08
        %         ind      = or(and(M1==1.12,M2==5.08),and(M1==5.08,M2==1.12));
        %         M1_12508 = M1(ind); %M1_12508 = M1_12508 + linspace(-0.75,0.75,length((M1_12508)))'; M1_12508 = M1_12508(randperm(length(M1_12508)));
        %         M2_12508 = M2(ind); %M2_12508 = M2_12508 + linspace(-0.75,0.75,length((M2_12508)))';
        %         D_12508  = D(ind);
        
        % Contruct data for m1=1.4||m2=10
        ind     = and(M1==1.4,M2==10);
        M1_1410 = M1(ind); M1_1410 = M1_1410 + linspace(-0.75,0.75,length((M1_1410)))'; M1_1410 = M1_1410(randperm(length(M1_1410)));
        M2_1410 = M2(ind); M2_1410 = M2_1410 + linspace(-0.75,0.75,length((M2_1410)))';
        D_1410  = D(ind);
        M_1410  = M(ind);
        
        % Apeend data
        M1 = [ M1_14-1.4+2 ; M1_03-3+4 ; M1_10-10+6; M1_1410-1.4+2];
        M2 = [ M2_14-1.4+2 ; M2_03-3+4 ; M2_10-10+6; M2_1410-10+6];
        D  = [ D_14  ; D_03  ; D_10;  D_1410];
        M  = [ M_14  ; M_03  ; M_10;  M_1410];
        
    elseif strcmp(RUN,'S6')
        % Read data
        m     = csvread([IFO '_s6cbc_simple.txt'],1,0);
        
        m     = m(1:end-6,:);
        %         % Eliminar si D==0
        %         M1(D==0) = [];
        %         M2(D==0) = [];
        %         M(D==0)  = [];
        %         D(D==0)  = [];
        
        % Get info
        M1    = m(:,2);
        M2    = m(:,3);
        D     = m(:,4);
        
        % Compute total mass
        M     = M1 + M2;
        
    elseif strcmp(RUN,'O1CBC')
        
    else
        error('PILAS: unknown run')
    end % if strmcp(RUN,'S5')
    clear ans m
    

    % Plot distribution of masses. Option 1
    figure
    
    scatter(M1,M2,12*M,1*D,'o','filled','MarkerEdgeColor','k') % 
    xlabel('$m_1$','Interpreter','Latex','FontSize',12)
    ylabel('$m_2$','Interpreter','Latex','FontSize',12)
    title([RUN ' - ' IFO])
    box on   
    if strcmp(RUN,'S5')
        axis([1 7 1 7])
        set(gca,'Xtick',[2 4 6],'Ytick',[2 4 6])
        set(gca,'XtickLabel',[1.4 3 10],'YtickLabel',[1.4 3 10])
        
        h=colorbar;
        set(h,'Location','East','YLim',[0 150],'YTick',[0.1 50 100 150])
        set(h,'Position',[0.8476    0.4148    0.0476    0.2110])
        text(6,4,'$D$','Interpreter','Latex')
    elseif strcmp(RUN,'S6')
        axis([0 31 0 31])
        
        h=colorbar;
        set(h,'Location','East','YLim',[10 90],'YTick',20:20:80)
        set(h,'Position',[0.8476    0.3548    0.0476    0.3619])
        text(26,16,'$D$','Interpreter','Latex')
    end
%     return

    
    
    
    
    % Grafica interna
    if strcmp(RUN,'S5')
        handaxes2 = axes('Position', [0.6 0.18 0.2 0.2]);        
        x = [2.8 4.2 6 8 11.4 15 20];
        h = hist(M,x);
        bar(x,h)
    elseif strcmp(RUN,'S6')
        handaxes2 = axes('Position', [0.55 0.70 0.2 0.2]);
        hist(M);
    end
    h         = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.8 0.8 0.8],'EdgeColor','k')
    xlabel('$M$','Interpreter','Latex','FontSize',8)
    ylabel('N','Interpreter','Latex','FontSize',8)
    box on, set(handaxes2,'FontSize',8)
    if strcmp(RUN,'S5')
        set(gca,'XLim',[0 22])
        set(gca,'Xtick',[2.8 6 11.4 20],'Ytick',[0 100 200 300 400])
    elseif strcmp(RUN,'S6')
        set(gca,'Xtick',[0 10 20 30 40],'Ytick',[0 100 200 300])
    end
    
    
end % if (0)
% clear ans RUN IFO M 