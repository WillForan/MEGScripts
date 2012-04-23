function [ index ] = getFixPeriods( data, thresh, window )
%This function will take a vector of input data, move a window
%along the time axis, check the min and max of data within the window
%against a preset threshold, and find periods of fixation
%
%   Input:
%       data - a vector of data
%       thresh - a threshold use to identify of boundries of fixation
%       window - min window length of fixation (not absoulute time but
%       number of data points)
%   Output:
%       index - columns of start and end time indices of fixation periods
%
%   Last update: 4.22.2011
%   By Kai


index=[];
i=1;
while i < (length(data)-window)
    
   
    TempWindow = data(i:i+window-1);  %create temporal window
    minData = min(TempWindow);
    maxData = max(TempWindow);
    RangeOfTempWindow = abs(maxData - minData);  %range within window
    
    if RangeOfTempWindow <= thresh % check against threshold
        
        startIndex = i;
        Nwindow = window;
            
       while RangeOfTempWindow < thresh
            
            Nwindow = Nwindow + 1; %while within range, lengthen window
            
            if (startIndex+Nwindow) < length(data) %make sure window doesnt exceed data length
            
                TempWindow = data(startIndex:startIndex+Nwindow-1);
                minData = min(TempWindow);
                maxData = max(TempWindow);
                RangeOfTempWindow = abs(maxData - minData);
            
            else
                break
            end
            
        end
        
        
        endIndex = startIndex+Nwindow-1;
        index = [index; startIndex, endIndex]; %output: columns of start and end time indices of fixation period
        i = endIndex +1;
    
    elseif RangeOfTempWindow > thresh
    
        i = i+1;
    
    end 
end


end

