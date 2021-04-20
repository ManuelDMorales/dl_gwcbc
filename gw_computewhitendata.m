function data_out = gw_computewhitendata(data,Twindow,BPFbanda,TW2reject,doplot)
% Compute the whitening of the strain data
% Whitening: transform to freq domain, divide by ASD, then transform back, 
% 
% Twindow   -->
% TW2reject -->

% just for debug
%Twindow = 8;
%BPFbanda = [20 1000];
%TW2reject = 16;
%doplot = 1;


%% INITIALIZE STRUCTURES

% if ~isfield(data,'timegps')
%     data.timegps = data.t;
% end

% Raw data
data_raw         = [];
data_raw.st      = data.st;
data_raw.t       = data.t;
data_raw.timegps = data.timegps;
data_raw.sf      = [];
data_raw.f       = [];
data_raw.psd     = [];
data_raw.fpsd    = [];
data_raw.fs      = data.fs;

% Whitened data
data_whi         = [];
data_whi.st      = [];
data_whi.t       = data.t;
data_whi.timegps = data.timegps;
data_whi.sf      = [];
data_whi.f       = [];
data_whi.psd     = [];
data_whi.fpsd    = [];
data_whi.fs      = data.fs;

% Whitened plus band-pass filtered data
data_out         = [];
data_out.st      = [];
data_out.t       = data.t;
data_out.timegps = data.timegps;
data_out.sf      = [];
data_out.f       = [];
data_out.psd     = [];
data_out.fpsd    = [];
data_out.fs      = data.fs;



%% COMPUTE DATA WITHENING


% ------------------------------
% Compute the PSD of the raw strain data

Nsamples                     = length(data_raw.st);
if mod(Nsamples,2)==1
    error('PILAS PERRO: Nsamples is odd')
end
% Twindow                      = 4; % Twindow == 4 for GW150914
NFFT                         = Twindow*data_raw.fs;

% Compute the single-sided PSD of the raw strain data 
[data_raw.psd,data_raw.fpsd] = pwelch(data_raw.st,hann(NFFT),[],NFFT,data_raw.fs);

% Compute the Nsamples/2+1 points single-sided PSD of the raw strain data
data_raw.fpsdss              = data_raw.fs *(0:1:Nsamples/2)'/Nsamples;
data_raw.psdss               = interp1(data_raw.fpsd,data_raw.psd,abs(data_raw.fpsdss));

% Compute the Nsamples-points double-sided PSD of the raw strain data
data_raw.fpsdds              = data_raw.fs * linspace(0,1,Nsamples)';
data_raw.psdds               = [data_raw.psdss ; fliplr(data_raw.psdss(2:end-1)')'];


% ------------------------------
% Compute Nsamples-points two-sided fft of the raw strain data
%data_raw.sf                  = fft(data_raw.st .* hamming(length(data_raw.st)));
data_raw.sf                  = fft(data_raw.st);
data_raw.f                   = data_raw.fs * linspace(0,1,Nsamples)';


% ------------------------------
% Compute the frequency-domain whitened strain signal
data_whi.sf        = data_raw.sf ./ sqrt(data_raw.psdds);
% data_whi.sf        = data_raw.sf ./ ( 1e21 * sqrt(data_raw.psdds /(1/data_raw.fs)/2) );
% data_whi.sf        = data_raw.sf ./ ( 1e23 *sqrt(data_raw.psdds) );
data_whi.f         = data_raw.f;

% Compute and apply scaling factor to the frequency-domain whitened strain
ind                = and(data_raw.fpsd>=90,data_raw.fpsd<=200);
sf                 = mean(sqrt(data_raw.psd(ind)));
data_whi.sf        = sf * data_whi.sf;

% Compute the time-domain whitened strain signal
data_whi.st       = ifft(data_whi.sf);

% Compute the single-sided PSD of the whitened strain data
[data_whi.psd,data_whi.fpsd] = pwelch(data_whi.st,hann(NFFT),[],NFFT,data_whi.fs);



%% BAND PASS FILTERING OF THE WITHENED STRAIN DATA

% ------------------------------
% Desing a band-pass filter of the whitened strain data
[b,a] = butter(4,BPFbanda/(data_whi.fs/2),'bandpass');
if (0)
    [fresponse,ffreq] = freqz(b,a,data_whi.fs/2);
    frecuencia        = ffreq/pi*data_whi.fs/2;
    respuesta         = abs(fresponse);
    
    figure
    plot(frecuencia,respuesta,'w','LineWidth',2)
    xlabel('Frequency (Hz)'), ylabel('Amplitud'), title('Filter Response')
    set(gca,'XScale','Log','YScale','Linear')
    axis([0 data_whi.fs/2 0 1.2]); grid on
    set(gca,'color',[.2 .5 .3]);
end % if (0)


% ------------------------------
% Band pass filtering of the whitened strain data
data_out.st       = filtfilt(b,a,data_whi.st);

% Reject TR seconds at the beginning and at the end of the pre-proc data
TR                = TW2reject; % TW2reject == 2 for GW150914
data_out.st       = data_out.st(TR*data_out.fs+1:end-TR*data_out.fs,1);
data_out.t        = data_out.t(TR*data_out.fs+1:end-TR*data_out.fs,1);
data_out.t        = data_out.t - data_out.t(1); % OJO: esta line si GW150
data_out.timegps  = data_out.timegps(TR*data_out.fs+1:end-TR*data_out.fs,1);

data_out.TW2reject = TW2reject;

% % Compute Nsamples-points two-sided fft filtered and whitened strain data
% data_out.sf     = fft(data_out.st);
% data_out.f      = data_out.fs*linspace(0,1,Nsamples)';

% Compute the single-sided PSD of the filtered and whitened strain data
[data_out.psd,data_out.fpsd] = pwelch(data_out.st,hann(NFFT),[],NFFT,data_out.fs);



%% PLOT FOR DEBUGGING
if (doplot)
    
    % Time domain signals
    figure    
    
    subplot(3,1,1)
    plot(data_raw.t,data_raw.st,'-','Color',[1.0 0.0 0.0],'LineWidth',1), hold on
    set(gca,'XLim',[data_raw.t(1) data_raw.t(end)]), %set(gca,'XLim',[-0.1 0.05]+16.4414),
    %set(gca,'YLim',[-1e-18 1e-18]),
    xlabel('Time (s)'), ylabel('Strain (unitless)')
    title('s_{raw}(t)')
    
    subplot(3,1,2)
    plot(data_whi.t,data_whi.st,'-','Color',[0.0 0.5 0.0],'LineWidth',1), hold on
    set(gca,'XLim',[data_whi.t(1) data_whi.t(end)]), %set(gca,'XLim',[-0.1 0.05]+16.4414),
    set(gca,'YLim',[-14e-21 14e-21]),
    xlabel('Time (s)'), ylabel('Strain (unitless)')
    title('s_{white}(t)')
        
    subplot(3,1,3)
    plot(data_out.t+16,data_out.st,'-','Color',[0.0 0.0 1.0],'LineWidth',1), hold on
    set(gca,'XLim',[data_whi.t(1) data_whi.t(end)]), %set(gca,'XLim',[-0.1 0.05]+16.4414),
    set(gca,'YLim',[-9e-21 9e-21]),
    xlabel('Time (s)'), ylabel('Strain (unitless)')
    title('s_{white+bpf}(t)')
        
    print('t_signals','-depsc')
        
    %     % Magnitude spectrum
    %     figure
    %
    %     plot(data_raw.f,abs(data_raw.sf),'-','Color',[1.0 0.0 0.0],'LineWidth',1), hold on
    %     set(gca,'XScale','Linear','YScale','Log')
    %     xlabel('Frequency (Hz)'), ylabel('|S_{raw}(f)| (?)')
    %     title('Magnitude Spectrum')
    %     grid on, box on
    %
    %     plot(data_whi.f,abs(data_whi.sf),'-','Color',[0.0 0.5 0.0],'LineWidth',1), hold on
    %     set(gca,'XScale','Linear','YScale','Log')
    %     xlabel('Frequency (Hz)'), ylabel('|S_{white}(f)| (?)')
    %     title('Magnitude Spectrum')
    %     grid on, box on
    %
    %     plot(data_out.f,abs(data_out.sf),'-','Color',[0.0 0.0 1.0],'LineWidth',1), hold on
    %     set(gca,'XScale','Linear','YScale','Log')
    %     xlabel('Frequency (Hz)'), ylabel('|S_{white+bpf}(f)| (?)')
    %     title('Magnitude Spectrum')
    %     grid on, box on
    
    
    % Amplitude Spectral Density
    figure
    plot(data_raw.fpsd,sqrt(data_raw.psd),'-','Color',[1.0 0.0 0.0],'LineWidth',1), hold on
    set(gca,'XScale','Log','YScale','Log')
    %xlabel('Frequency (Hz)'), ylabel('ASD (Hz^{-1/2})')
    %title('ASD_{raw}(f)')
    grid on, box on
    
    plot(data_whi.fpsd,sqrt(data_whi.psd),'-','Color',[0.0 0.5 0.0],'LineWidth',1), hold on
    set(gca,'XScale','Log','YScale','Log')
    %xlabel('Frequency (Hz)'), ylabel('ASD (Hz^{-1/2})')
    %title('ASD_{white}(f)')
    grid on, box on
    
    plot(data_out.fpsd,sqrt(data_out.psd),'-','Color',[0.0 0.0 1.0],'LineWidth',1), hold on
    set(gca,'XScale','Log','YScale','Log')
    %xlabel('Frequency (Hz)'), ylabel('ASD (Hz^{-1/2})')
    %title('ASD_{white+bpf}(f)')
    grid on, box on
    
    xlim([10^(-1) 3*10^3])
    ylim([10^(-34) 10^(-15)])
    
    xlabel('Frequency (Hz)'), ylabel('ASD (Hz^{-1/2})')
    title('Amplitude Spectral Density')
    
    legend({'Raw','White','White+BPF'},'Location','best','FontSize',12)
    
    print('ASD','-depsc')
        
end % if (doplot)





