function data = gw_computegetdata(ligo,doplot)
% Compute h(t) using 2PN aproximation
% Compute h(f) using the stationary phase aproximation

% ventana de datos, eliminar bordes por cuestiones de discontinuidad

%% GET DATA SEGMENT

% Initialize data segment structure
data.st                    = [];
data.t                     = [];
% data.timegps               = [];
data.sf                    = [];
data.f                     = [];
data.psd                   = [];
data.fpsd                  = [];

% Compute the window the data segment
data.st_window             = blackman(ligo.NFFT);
% Construct inverse window 
data.inv_win               = (1./data.st_window);

% Reject 20 seconds on edges due to window edge effects
tr                         = ceil(0.15*ligo.segments.Twin);
ind2eli                    = 1:tr*ligo.fs;
data.inv_win(ind2eli)      = 0;
ind2eli                    = length(data.inv_win)-tr*ligo.fs:length(data.inv_win);
data.inv_win(ind2eli)      = 0;

% Get the data segment
iseg                       = ligo.segments.seginj;
data.st                    = ligo.strain(ligo.segments.Sint(iseg,1):ligo.segments.Sint(iseg,2));
data.t                     = ligo.timegps(ligo.segments.Sint(iseg,1):ligo.segments.Sint(iseg,2));
% data.timegps               = ligo.timegps(ligo.segments.Sint(iseg,1):ligo.segments.Sint(iseg,2));
% data.t                     = data.timegps-data.timegps(1); 

% Compute single-sided FFT of the data segment
data.sf                    = fft(data.st .* data.st_window,ligo.NFFT);
data.sf                    = data.sf(1:(ligo.NFFT/2)+1);
data.f                     = ( linspace(0,ligo.fs/2,length(data.sf)) )';

% Save other info
data.fs                    = ligo.fs;
data.NFFT                  = ligo.NFFT;


% Save injection info
data.injection             = ligo.injection;

% Clear garbage
clear ans tr ind2eli iseg


% Plot dtrain data sigle-sided FFT
if (doplot)
    
    figure, hold on
    
    subplot(2,1,1), hold on
    plot(data.t-data.t(1),data.st,'k')
    line([ligo.injection.GPS ligo.injection.GPS]-data.t(1),[-1e-10 1e-10],'Color',[1 0 0])
    %grid on, box on
    xlabel('Time (gps)'), ylabel('strain'), title(['Start=' num2str(data.t(1)-data.t(1)) ' | ' 'End=' num2str(data.t(end)-data.t(1))  ' | ' 'Coal=' num2str(ligo.injection.GPS-data.t(1))])
    set(gca,'Xlim',[data.t(1) data.t(end)]-data.t(1),'Ylim',[-1e-15 1e-15]), box on
    
    subplot(2,1,2), hold on
    plot(data.f,abs(data.sf),'k','LineWidth',2)
    grid on, box on
    xlabel('Frequency   [Hz]'), ylabel('Spectral Power [Hz^{-1/2}]'), title('s(f): Strain data sigle-sided FFT')
    set(gca,'XLim',[1 data.injection.fs/2],'XScale','Log','YScale','Log')
    
    
%     % GRAFICA PARA PAPER/PRESENTACION: PILAS: poner injection.NFFT a []
%     figure, hold on
%     plot(data.f,abs(data.sf),'k','LineWidth',2)
%     grid on, box on
%     xlabel('Frequency   [Hz]'), ylabel('Spectral Power [Hz^{-1/2}]'), title('s(f): Strain data sigle-sided FFT')
%     set(gca,'XLim',[1 data.injection.fs/2],'XScale','Log','YScale','Log')
%     %set(gca,'XTickLabel',[ ],'YTickLabel',[])
end



%% FILTER STRAIN DATA

% [b, a]          = butter(4,[template.prm.flow/(ligo.fs/2),ceil(template.prm.fisco)/(ligo.fs/2)],'bandpass');
% data.stfilt     = filter(b,a,data.st);