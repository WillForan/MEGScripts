function Output = MEG_Granger(X,Window,samFS,FOI,ModelOrder,tstep)
% This function will run Granger causal connectivity analyses. The
% input is a 3-D data, where x is number of variables, y is number of
% observation on the time axis, and z is number of trials. This is a moving
% window analysis, which mean causality will be evaluated in a window
% length specified and move along the time axis.
% This function will call functions from Anil Seth's Causal Connectivity
% Toobox to perform GCA. BSMART toolbox will also need to be in your matlab
% path.
%   
%
% usage:    Output = MEG_Granger(X,Window,samFS,FOI)
%   Input:
%       X - input data array, x is variable, y is time, z is number of
%       trials
%       Windoq - the length of window you want connectivity to be evaulated.
%       samFS - the sampling frequency in hz
%       FOI - vector of frequency of interest, such as [1:100]
%       ModelOrder - model order use in mvar.
%       tstep - time step you want to use for moving down the time axis
%
%   Output:
%       Output.GW, a 4D array GC measures of nvar*nvar*Fz*time
%       Output.coh, same as above but here its coherence
%
%   To do: 1. Give option to esitmate model order
%          2. Give option to do consistency test
%
%   Last update May 6, 2011, by Kai
%
%   updates: ``1. May 6, clean powerline noise with cca_multitaper
%

nobs = size(X,2);
nvar = size(X,1);
ntrials = size(X,3);




%clean powerline noise
for r1= 1:nvar
    for r2 =1:ntrials
        X(r1,:,r2)=cca_multitaper(X(r1,:,r2), samFS, 60, 100);
    end
end

Output.GW=[];
Output.Coh=[];
for n = 1:tstep:nobs-Window
    
    %re-chop data for cca_pwcausal
    Data = X(:,n:n+Window,:);
    [a,b,c]=size(Data);
    Data=reshape(Data,[a,b*c]);
    
    Data=cca_rm_ensemblemean(Data,ntrials,b);
    %[~,aic]=cca_find_model_order_mtrial(Data,ntrials,b,1,round(b/2));
    %aic
    [GW,Coh,~]=cca_pwcausal(Data,ntrials,b,ModelOrder,samFS,FOI,0);
    %size(GW)
    Output.GW(1:nvar,1:nvar,1:FOI(end),n)=GW;
    Output.Coh(1:nvar,1:nvar,1:FOI(end),n)=Coh;
end



