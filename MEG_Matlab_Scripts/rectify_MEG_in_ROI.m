function [rectified_data]=rectify_MEG_in_ROI(ROI_in)

rectified_data=ROI_in;

for i = 1:3
    mean_rectified_data=mean(rectified_data);
    for j = i:size(rectified_data,1)
        if corr(mean_rectified_data',rectified_data(j,:)')<-.3
            rectified_data(j,:)=-rectified_data(j,:);
        end
    end
end
