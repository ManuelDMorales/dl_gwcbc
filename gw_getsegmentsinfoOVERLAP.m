function Segments = gw_getsegmentsinfoOVERLAP(Tblock,Twin,Tove,fs)
%
% % Funciona cualquier overlap 
% % Example:
% Tblock  = 4096;
% Twin    = 32;
% Tove    = 4;
% fs      = 4096;

% Initialize
Segments        = [];

% Duration of the segment
Segments.Tblock = Tblock;

% Duration of the data window and overlap (seconds)
Segments.Twin   = Twin;
Segments.Tove   = Tove;

% Time ini and Time end of each window (seconds)
Tini            = (0:Twin-Tove:Tblock-Twin)';
Tend            = Tini+Segments.Twin;
% [Tini Tend]

% Sample ini and Sample end of each window (sample)
% remark: sample = index for each data point in time vector
Sini            = Tini*fs+1;
Send            = Tend*fs+0;

% Time and samples of each window (interval)
Segments.Tint   = [Tini Tend];
Segments.Sint   = [Sini Send];
% [Sini-Send]/fs

% Number of segments
Segments.Nseg   = size(Segments.Sint,1);

% Clear garbage
clear ans Tini Tend Sini Send




