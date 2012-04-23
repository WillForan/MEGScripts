function out = ilabFilter(b,a,x)
%ILABFILTER Filter a vector with zero phase distortion
%  OUT = ILABFILTER(B, A, X) filters the data in vector X with the filter described
%  by A and B.  The filter is described by the difference equation:
%
%    y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%                     - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
%  Signals are filtered in the forward and then reverse direction. The output 
%  has zero phase distortion. The technique of Gustafsson is used to match
%  initial conditions in order to minimize the starting and ending transients.
%
%  The length of the input x must be more than three times
%  the filter order, defined as max(length(b)-1,length(a)-1).
%
%  If there are NaN's in the data, e.g., from blink filtering then the data
%  are filtered twice, first with the NaN's set to 0 and then with the
%  NaN's set to one. Any points that change must be next to the NaN's and
%  are removed.
%
%  References: 
%    [1] Sanjit K. Mitra, Digital Signal Processing, 2nd ed., McGraw-Hill, 2001
%    [2] Fredrik Gustafsson, Determining the initial states in forward-backward 
%        filtering, IEEE Transactions on Signal Processing, pp. 988--992, April 1996, 
%        Volume 44, Issue 4
%
%  This function is based on Matlab's filtfilt function. It only deals with
%  vectors, and removes NaN's.

% Authors: Darren Gitelman
% $Id: ilabFilter.m 127 2010-06-11 06:26:58Z drg $


if length(x) <= length(b)-1
    out = [];
    return
end

if min(size(x)) > 1
    errordlg('ilabFilter only operates on vectors.','ILAB FILTER ERROR','modal');
    return
end

b = b(:)';
a = a(:)';
nb = length(b);
na = length(a);
szfilt = max(nb,na);
szedge = 3*(szfilt-1);

% equalize coefficient sizes
if nb < na
    b(na) = 0;
elseif na < nb
    a(nb) = 0;
end

% use equation from Gustafsson
zi = ( eye(szfilt-1) - [-a(2:szfilt)' [eye(szfilt-2); zeros(1,szfilt-2)]] ) \ ...
     ( b(2:szfilt)' - a(2:szfilt)'*b(1) );
 
% flip beginning and end of data sequence and tack on.
y = [2*x(1)-flipud(x(2:szedge+1,:));  x; 2*x(end) - flipud(x(end-szedge:end-1))];

% find NaNs
 yNANidx = find(isnan(y));

 % if there are no NaN's then perform standard filtering.
 % if there are NaN's then filter the data in 2 ways; first substitute 0
 % for the NaN points and then substitute 1. Find the points that differ
 % between these methods. These are the ones next to the NaN data.
 % Remove them.
 if isempty(yNANidx)
     y = filterit(b,a,zi,y);
 else
     y(yNANidx) = 0;
     y1 = filterit(b,a,zi,y);

     y(yNANidx) = 1;
     y2 = filterit(b,a,zi,y);
     
     chgidx = find(y1 ~= y2);
     
     y = y1;
     y(chgidx)  = NaN;
     y(yNANidx) = NaN;
 end

% remove extra pieces of y
out = y(szedge+1:end-szedge);
return

%=======================================================================

function y = filterit(b,a,zi,y)

% filter, reverse data, filter again, and reverse data again
% b is normalized by sum(b) so that output has same magnitude as the input.
y = filter(b/sum(b),a,y,[zi*y(1)]);
y = flipud(y);
y = filter(b/sum(b),a,y,[zi*y(1)]);
y = flipud(y);
