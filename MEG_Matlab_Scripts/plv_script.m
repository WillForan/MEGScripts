%Script to do PLV analyses. Will select trials from each condition.

%% do ANTI PLV
for n=1:5
    %only analyze correct trials
    fcg{n}=[];
    fcg{n}.method='plv';
    fcg{n}.channelcmb = 'all';
    % All trials
    fcg{n}.trials = find(TFR{n}.trialinfo(:,1)==1 ...
        & (TFR{n}.trialinfo(:,2)==1 | TFR{n}.trialinfo(:,2)==2 ...
        | TFR{n}.trialinfo(:,2)==1 | TFR{n}.trialinfo(:,2)==2))';  
end

for n=1:5
	ANTI_PLV{n} = ft_connectivityanalysis(fcg{n}, TFR{n});
end

save ANTI_PLV.mat ANTI_PLV

%% do ANTI_L PLV
for n=1:5
    %only analyze correct trials
    fcg{n}=[];
    fcg{n}.method='plv';
    fcg{n}.channelcmb = 'all';
    % All trials
    fcg{n}.trials = find(TFR{n}.trialinfo(:,1)==1 ...
        & (TFR{n}.trialinfo(:,2)==1 | TFR{n}.trialinfo(:,2)==1 ...
        | TFR{n}.trialinfo(:,2)==1 | TFR{n}.trialinfo(:,2)==1))';  
end

for n=1:5
	ANTI_Left_PLV{n} = ft_connectivityanalysis(fcg{n}, TFR{n});
end

save ANTI_Left_PLV.mat ANTI_Left_PLV

%% do ANTI_R_PLV

for n=1:5
    %only analyze correct trials
    fcg{n}=[];
    fcg{n}.method='plv';
    fcg{n}.channelcmb = 'all';
    % All trials
    fcg{n}.trials = find(TFR{n}.trialinfo(:,1)==1 ...
        & (TFR{n}.trialinfo(:,2)==2 | TFR{n}.trialinfo(:,2)==2 ...
        | TFR{n}.trialinfo(:,2)==2 | TFR{n}.trialinfo(:,2)==2))';  
end

for n=1:5
	ANTI_Right_PLV{n} = ft_connectivityanalysis(fcg{n}, TFR{n});
end

save ANTI_Right_PLV.mat ANTI_Right_PLV

%% VGS!

%% do VGS PLV
for n=1:5
    %only analyze correct trials
    fcg{n}=[];
    fcg{n}.method='plv';
    fcg{n}.channelcmb = 'all';
    % All trials
    fcg{n}.trials = find(TFR{n}.trialinfo(:,1)==1 ...
        & (TFR{n}.trialinfo(:,2)==3 | TFR{n}.trialinfo(:,2)==4 ...
        | TFR{n}.trialinfo(:,2)==3 | TFR{n}.trialinfo(:,2)==4))';  
end

for n=1:5
	VGS_PLV{n} = ft_connectivityanalysis(fcg{n}, TFR{n});
end

save VGS_PLV.mat VGS_PLV

%% do VGS_L PLV
for n=1:5
    %only analyze correct trials
    fcg{n}=[];
    fcg{n}.method='plv';
    fcg{n}.channelcmb = 'all';
    % All trials
    fcg{n}.trials = find(TFR{n}.trialinfo(:,1)==1 ...
        & (TFR{n}.trialinfo(:,2)==3 | TFR{n}.trialinfo(:,2)==3 ...
        | TFR{n}.trialinfo(:,2)==3 | TFR{n}.trialinfo(:,2)==3))';  
end

for n=1:5
	VGS_Left_PLV{n} = ft_connectivityanalysis(fcg{n}, TFR{n});
end

save VGS_Left_PLV.mat  VGS_Left_PLV

%% do VGS_R_PLV

for n=1:5
    %only analyze correct trials
    fcg{n}=[];
    fcg{n}.method='plv';
    fcg{n}.channelcmb = 'all';
    % All trials
    fcg{n}.trials = find(TFR{n}.trialinfo(:,1)==1 ...
        & (TFR{n}.trialinfo(:,2)==4 | TFR{n}.trialinfo(:,2)==4 ...
        | TFR{n}.trialinfo(:,2)==4 | TFR{n}.trialinfo(:,2)==4))';  
end

for n=1:5
	VGS_Right_PLV{n} = ft_connectivityanalysis(fcg{n}, TFR{n});
end

save VGS_Right_PLV.mat VGS_Right_PLV
