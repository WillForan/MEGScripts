function Out=find_trigger(E,T)
% This function will find MEG triggers. And will return vector of trigger
% index. Note for repeateing triggers this function will only
% return the first index.
%
%   usage: Out=find_trigger(E,T)
%   E = trigger value of interest
%   T = vector of trigger line data
%   Out = vector of trigger indices
%
%   Last udpate: 9.26.2011
%   By Kai


List=[];
for n = 2:1:size (T,2)
    if T(n) == E && T(n+1)==0
        List=[List,n];
        
    end

end

Out=List;