function Z = zTFplot( TF, BaselineLength, TimeVec, FOI, Threshold, FigTitle )
%This function will plot a normalized (pseudo-z) time-frequency plot.
%   usage: zTFplot( TF, BaselineLength, TimeVec, FOI,Threshold, FigTitle  )
%   Input:
%       TF - the time-freuqnecy matrix, row is freq, column is time
%       BaselineLength -the legth of baseline
%       TimeVec - the time fector
%       FOI - the frequency range
%       Threshold - threshold the data with absolute valume, if don't want
%       to threshold can simply set this to -9999
%       FigTitle - title of figure    
%
%   Output: 
%       Z - z score of time-frequency matrix.
%   
%   Last update Narch 11 2012, by Kai
%


BaselineVec = TF(:,1:BaselineLength);

BaseMean = mean(BaselineVec,2);

BaseSD = std(BaselineVec,0,2);

%calculate z
for n = 1:size(TF,2)
    %z score
    Z(:,n) = (TF(:,n)-BaseMean)./BaseSD;
    
    % percentage change
    %Z(:,n)=TF(:,n)./BaseMean;
end

% convert to percentage
%Z = (Z -1)*100;
%threshold
TBin = Z > Threshold;

Zthresh = Z.*TBin;

h=figure;

pcolor(TimeVec,FOI,Zthresh)
caxis([-3 3])
colorbar
shading flat
title(FigTitle);

end

