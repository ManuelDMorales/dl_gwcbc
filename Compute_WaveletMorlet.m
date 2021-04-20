function [ WL,timeVec,freqVec] = Compute_WaveletMorlet( data, fs, Fstart, Fstop, BinWidth, MorletWidth, doplot )
%
% 
% 
% 
%
% INPUT:
% data        -> Spatio-temporal data.  Nsamples x Nchannels
% fs          ->
% freqVec     ->
% MorletWidth -> 'width' of the morlet wavelet expressed in cycles
% doplot      ->
% 
% OUTPUT:
% WL        -> time-frequency representation. Nchannels x Nfreq x Nsamples
% 
%
% 
% -------------------------------------------------------------------------
% NOTE: This function is equivalent to the Time-Frequency-Representation
% analysis in FieldTrip for averaged trials with the following parameters:
% cfg              = [];
% cfg.output       = 'pow';
% cfg.channel      = 'all';
% cfg.method       = 'tfr'; % (mtmfft|mtmconvol|mtmwelch|wltconvol|tfr)
% cfg.foi          = 1:1:70;
% TFR              = ft_freqanalysis(cfg, avgData);



%% INITIALIZE SOME VARIABLES

% Width of the morlet wavelet expressed in cycles
% MorletWidth = 7;

% Compute number of channels and number of samples of the input data
[ Nsamples Nchannels ] = size(data);

% Compute the time vector and the time sampling
timeVec = (0:1:Nsamples-1)/fs;
Ts      = 1/fs;

% Compute the frequency vector
% Fstart  = 5;
% Fstop   = fs/2; if Fstop>50, Fstop=50; end
Nfreq   = round((Fstop-Fstart)/BinWidth)+1;
freqVec = linspace(Fstart,Fstop,Nfreq)'; 
% freqVec = (Fstart:BinWidth:Fstop)';
% Nfreq   = length(freqVec);

% Initialize the WL matriz for all the channels
WL = zeros(Nchannels,Nfreq,Nsamples);
%WLphase = zeros(Nchannels,Nfreq,Nsamples);



%% COMPUTE THE TIME-FREQUENCY REPRESENTATION

for ichan = 1:Nchannels
    
    % For the current temporal signal...
    Signal = data(:,ichan);
    Signal = detrend(Signal,'linear');
    
    % For each frequency...
    for ifre = 1:Nfreq
        
        %doplot_test = 0;
        %if ifre == ceil(Nfreq/4)
        %   doplot_test = 1;    
        %end 
        
        % Compute the morlet wavelet
            
        Morlet = Compute_Morlet(freqVec(ifre),Ts,MorletWidth);
                
        % Convolution of the current morlet wavelet with the signal
        WLcomplex  = conv(Signal,Morlet);
               
        % Get indexes
        li = ceil(length(Morlet)/2);
        ls = length(WLcomplex)-floor(length(Morlet)/2);
        
        % Complex coeffiecients
        WLcomplex = WLcomplex(li:ls);
        
        % Plot wavelet decomposition
        if (0)
            figure, hold on
            subplot(3,1,1), hold on
            plot(real(WLcomplex),'r'), plot(imag(WLcomplex),'b'), legend('real','imag'), box on
            title(['Frequency: ' num2str(freqVec(ifre)) ' Hz'])
            subplot(3,1,2), hold on
            plot(abs(WLcomplex)), legend('magnitude'), box on
            subplot(3,1,3), hold on
            plot(angle(WLcomplex)), legend('phase'), box on
            pause
            print('wavelet_decomposition','-depsc')
        end
        
        % Compute the magnitud
        WLmag  = 2*(abs(WLcomplex).^2)/fs;
        
        % % % Compute the phase
        % % WLphase = angle(WLcomplex);
        
        % Save wavelet decomposition magnitude
        WL(ichan,ifre,:)  = WLmag;
        
    end
    
end

if ichan==1
    WL = squeeze(WL);
    %WLphase = squeeze(WLphase);
end


if (doplot)
    % plot the across-channels average wavelet
    figure, clf, hold on
    [X,Y] = meshgrid(timeVec,freqVec);
    Z = zeros(size(X));
    
    if ichan==1
        WL2plot = WL;
        titulo = 'Time-Frequency representation';
    else
        %WL2plot = squeeze(mean(WL,1));
        %titulo = 'Across-channels mean Time-Frequency representation';
        
        % Plot scalogram for the first signal
        WL2plot = squeeze(WL(1,:,:));
        titulo = 'Time-Frequency representation';
    end
    
    surface(X,Y,Z,WL2plot,'EdgeColor','none','FaceColor','interp');
    contour(X,Y,WL2plot,6,'w');
    
    axis([min(timeVec) max(timeVec) min(freqVec) max(freqVec)])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    title(titulo)
    box on
    colorbar
end


function Morlet = Compute_Morlet(fi,Ts,MorletWidth)
% COMPUTE THE MORLET WAVELET FOR FREQUENCY "fi" AND TIME "t"
% The wavelet will be normalized so the total energy is 1.
% 'MorletWidth' defines the width of the wavelet. (width>= 5 is suggested)
% 
% PILAS: THIS FUNCTION HAS BEEN COPY FROM THE OPEN SOURCE FIELDTRIP TOOLBOX
% Reference: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)

sf = fi/MorletWidth;
st = 1/(2*pi*sf);

t  = -3.5*st:Ts:3.5*st;

A  = 1/sqrt(st*sqrt(pi));

Morlet  = A*exp(-t.^2/(2*st^2)).*exp(1i*2*pi*fi.*t);

% Plot the Morlet wavelet
if (0)
     
    figure
    subplot(3,1,1), hold on
    plot(t,real(Morlet),'r','LineWidth',2), plot(t,imag(Morlet),'b','LineWidth',2)
    ylabel('Morlet'), legend('Real','Imag'), box on
    title(['Frequency = ' num2str(fi) 'Hz'])
    subplot(3,1,2), plot(t,abs(Morlet),'.-r'), %axis([-4 4 0 6])
    xlabel('Time (s)'), ylabel('Magnitude')
    subplot(3,1,3), plot(t,angle(Morlet),'.-b'), %axis([-4 4 -4 4])
    xlabel('Time (s)'), ylabel('Angle')
    
    pause
end





