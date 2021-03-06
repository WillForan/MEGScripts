function [ data, BehavStats ] = ScoreMEGSaccades( subj_id, Inputdata, TrigVector, CorrectVector)
%This function will score the saccade table generated by
%EOGExtractSaccades function.
%   Usage: [data, BehavSts] = ScoreMEGSaccade(subj_id, Inputdata, TrigVector, 
%                 CorrectVector)
%   inputs:
%           subj_id = id number
%           Inputdata - Path to load saccade talbe will be
%           subjid_anit_EOG_data.mat
%           TrigVector - a vector of triger codes for trial types of
%           interests. i.e., [25 35 65 75]
%           CorrectVector - a vector containing the direction of saccade of
%           each trial type, must be listed in the same order as
%           TrigVector. -1 is to right, 1 is to left. i.e., [-1 1 1 -1]
%
%   Output: A saccade table with accuracy scored, and a strcutre containing behavioral stats across runs
%   results will also be saved into subjid_anti_DATE_EOG_data.mat
%
%   last update 10.06.2011 by Kai Hwang

%% load data
load(Inputdata);

%loop through runs
runs = 1:1:size(data,2);

for run = runs
    %% construct the correct vecotr, correct saccade direction for each trial
    % only keep the first saccade of each trial
    VectorsToRemove = [];
    data{run}.Scored_saccadeTable = data{run}.saccadeTable;
    for i = 2:1:size(data{run}.Scored_saccadeTable,1)
        if data{run}.saccadeTable(i,1) == data{run}.saccadeTable(i-1,1)
            VectorsToRemove=[VectorsToRemove,i];
        elseif data{run}.saccadeTable(i,4) < 0.13  %eliminate express saccades, 130ms.
            VectorsToRemove=[VectorsToRemove,i];
        end
    end
    data{run}.Scored_saccadeTable(VectorsToRemove,:)=[]; %remove secondary saccades
       
    for i = 1:size(data{run}.Scored_saccadeTable,1)
        for n = 1:size(TrigVector,2)
            if data{run}.Scored_saccadeTable(i,3) == TrigVector(n);
                data{run}.Scored_saccadeTable(i,7) = CorrectVector(n);
            end
        end
    end
    
    %% score saccade table 
    % append new columns to the original saccade table for output
    % score saccade table, 1 is correct, 0 is incorrect/unscorable
    data{run}.Scored_saccadeTable(:,8)=data{run}.Scored_saccadeTable(:,6)==data{run}.Scored_saccadeTable(:,7);
    
end
%% Behavioral statistics
%TotalNumberTrials=length(find_trigger(PP.TrigTarget,PP.Trigs'));
%PrcentOfCorrectResponse=size(table,1)/length(find_trigger(PP.TrigTarget,PP.Trigs'));
BehavStats = [];
BehavStats.Total_Trial_Num = 0;
BehavStats.Total_Good_trial_Num = 0;
BehavStats.Scored_Trial_Num = zeros(1,size(TrigVector,2));
BehavStats.Scored_Correct_Trial_Num = zeros(1,size(TrigVector,2));
BehavStats.Scored_InCorrect_Trial_Num = zeros(1,size(TrigVector,2));
BehavStats.Scored_Correct_Trial_RT = cell(1,size(TrigVector,2));
BehavStats.Scored_InCorrect_Trial_RT = cell(1,size(TrigVector,2));
for run = runs
    BehavStats.Total_Trial_Num = BehavStats.Total_Trial_Num + (size(data{run}.trigger_values,2));
    BehavStats.Total_Good_trial_Num = BehavStats.Total_Good_trial_Num + size(data{run}.good_trigger_values,2);
    
    for i = 1:size(data{run}.Scored_saccadeTable,1)
        for n = 1:size(TrigVector,2)
            if data{run}.Scored_saccadeTable(i,3) == TrigVector(n);
                BehavStats.Scored_Trial_Num(n) = BehavStats.Scored_Trial_Num(n) + 1;
                
                if data{run}.Scored_saccadeTable(i,8) == 1;
                    BehavStats.Scored_Correct_Trial_Num(n) = BehavStats.Scored_Correct_Trial_Num(n) + 1;
                    BehavStats.Scored_Correct_Trial_RT{n} = [BehavStats.Scored_Correct_Trial_RT{n},  ...
                        data{run}.Scored_saccadeTable(i,4)];
                elseif data{run}.Scored_saccadeTable(i,8) == 0;
                    BehavStats.Scored_InCorrect_Trial_Num(n) = BehavStats.Scored_InCorrect_Trial_Num(n) + 1;
                    BehavStats.Scored_InCorrect_Trial_RT{n} = [BehavStats.Scored_InCorrect_Trial_RT{n},  ...
                        data{run}.Scored_saccadeTable(i,4)];
                end
            end
        end
    end
    
    for n = 1:size(TrigVector,2)
        BehavStats.Scored_Correct_Trial_Mean_RT(n) = mean(BehavStats.Scored_Correct_Trial_RT{n});
        BehavStats.Scored_Correct_Trial_STD_RT(n) = std(BehavStats.Scored_Correct_Trial_RT{n});
        BehavStats.Scored_InCorrect_Trial_Mean_RT(n) = mean(BehavStats.Scored_InCorrect_Trial_RT{n});
        BehavStats.Scored_InCorrect_Trial_STD_RT(n) = std(BehavStats.Scored_InCorrect_Trial_RT{n});
    end
end

BehavStats.Clean_Trial_Percentage = BehavStats.Total_Good_trial_Num / BehavStats.Total_Trial_Num;
BehavStats.Trial_Performance = BehavStats.Scored_Correct_Trial_Num ./ BehavStats.Scored_Trial_Num;
BehavStats.TrigVector = TrigVector;
BehavStats.CorrectVector = CorrectVector;

%% save output
% generate time stemp for saving
clock_temp = clock;
year_text = num2str(clock_temp(1));
year_text = year_text(end-1:end);
if clock_temp(2)>10
   month_text = num2str(clock_temp(2));
else
   month_text = ['0',num2str(clock_temp(2))];
end
if clock_temp(3)>10
   day_text = num2str(clock_temp(3));
else
  day_text = ['0',num2str(clock_temp(3))];
end
savefilename = [num2str(subj_id),'_anti_','EOG_Data'];

% save
save_dir=pwd;
disp(['Saving ' fullfile(save_dir,savefilename)]);
save(fullfile(save_dir,savefilename),'data','subj_id', 'BehavStats');

end

