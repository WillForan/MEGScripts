function filtered_channel = filter_channel (channel_data, sr, varargin);
% y=filter_channel(x, sample_rate, 'parameter','value',...)
%
% performs low-pass, high-pass and notch filtering (not all types need to be specified)
%
% parameters:
% - 'low': low pass filter cutoff (Hz)
% - 'high': high pass filter cutoff (Hz)
% - 'notch': notch filter frequency (Hz)
% Yigal Agam, jun-04-2007

if nargin<1
   error('Channel data not specified');
elseif nargin<2
   error('Sample rate must be specified');
elseif mod(nargin,2)==1
   error('Each argument must be assigned a value');
end
% parse arguments
for a=1:2:length(varargin)
   argument=lower(cell2mat(varargin(a)));
   value=cell2mat(varargin(a+1));
   eval([argument '=' num2str(value) ';']);
end
%filter
filter_depth=3;
filtered_channel=double(channel_data);
if exist('high') && high~=0
   [b,a]=butter(filter_depth,2*high/sr,'high');
   filtered_channel=filtfilt(b,a,filtered_channel);
end
if exist('low') && low~=0
   [b,a]=butter(filter_depth,2*low/sr,'low');
   filtered_channel=filtfilt(b,a,filtered_channel);
end
if exist('notch') && notch~=0
   [b,a]=butter(filter_depth,2*[notch-1 notch+1]/sr,'stop');
   filtered_channel=filtfilt(b,a,filtered_channel);
end