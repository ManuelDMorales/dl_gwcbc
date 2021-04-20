function Data = Compute_CNNeliminateSNR(Data,SNR2ELIM)

% SNR2ELIM: SNR limit value to eliminate

% ----------------------------------------
% Get data for class noise: 1
Ind_c0              = Data.Y(:,1)==1;
Y_c0                = Data.Y(Ind_c0,:);
TFR_c0              = Data.Xtfr(Ind_c0,:,:);

% ----------------------------------------
% Get data for class gw: 2
Ind_c1              = Data.Y(:,1)==2;
Y_c1                = Data.Y(Ind_c1,:);
TFR_c1              = Data.Xtfr(Ind_c1,:,:);

% ----------------------------------------
% Eliminate data for which SNR<=10
Ind2Eli             = Y_c1(:,5)<=SNR2ELIM;
Y_c0(Ind2Eli,:)     = [];
Y_c1(Ind2Eli,:)     = [];
TFR_c0(Ind2Eli,:,:) = [];
TFR_c1(Ind2Eli,:,:) = [];

% ----------------------------------------
% Construct data to keep
Data.Y              = [Y_c0   ; Y_c1  ];
Data.Xtfr           = [TFR_c0 ; TFR_c1];

% ----------------------------------------
% Clear garbage
clear ans Ind2Eli Ind_c1 Ind_c0 TFR_c0 TFR_c1 Y_c0 Y_c1


%% PLOT FOR DEBUGGING

% if (0)
%     
%     % ----------------------------------------
%     for i=1:1:size(Data.Y,1)/2
%         figure(1)
%         
%         subplot(2,1,1)
%         imagesc(Data.t,Data.f,squeeze(Data.Xtfr(i,:,:)))
%         xlabel('Time (s)'), ylabel('Frequency (Hz)'), title('n(t)')
%         colormap jet, view(0,90), box on, grid on, set(gca,'YDir','normal')
%         
%         subplot(2,1,2)
%         imagesc(Data.t,Data.f,squeeze(Data.Xtfr(i+size(Data.Y,1)/2,:,:)))
%         xlabel('Time (s)'), ylabel('Frequency (Hz)'), title(['n(t)+h(t)   |   SNR=' num2str(Data.Y(i+size(Data.Y,1)/2,5))])
%         colormap jet, view(0,90), box on, grid on, set(gca,'YDir','normal')
%         
%         pause(0.2)
%         
%     end % for i=1:1:size(Data.Y,1)/2
%     clear ans i
%     
%     % ----------------------------------------
%     % Return
%     return
% end % if (1)