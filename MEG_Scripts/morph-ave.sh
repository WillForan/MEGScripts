#!/bin/bash
cwd=$(pwd)

for s in 10896 10910 10911; do
	cd ${cwd}/${s}/MEG/
	
	for cond in anti_Correct anti_all vgs_Correct vgs_all all_Correct all_all; do
	
	while [`jobs | wc -l` -ge 16 ]
  	do
    		sleep 10
  	done
	
	#create STC files of current estimates in averaged surface
	mne_make_movie \
    --subject ${s} \
    --inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
    --meas ${s}_${cond}_ave.fif \
    --morph fsaverage \
    --smooth 5 \
    --stc ${s}_${cond}_fsaverage > ${s}_${cond}_fsaverage.log 2>&1 &
    
    while [`jobs | wc -l` -ge 16 ]
  	do
    		sleep 10
  	done
    
    mne_make_movie \
    --subject ${s} \
    --inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
    --meas  ${s}_${cond}_ave.fif \
    --morph fsaverage \
    --smooth 5 \
    --sLORETA \
    --stc ${s}_${cond}_loreta_fsaverage >  ${s}_${cond}_loreta_fsaverage.log 2>&1 &
    
    while [`jobs | wc -l` -ge 16 ]
  	do
    		sleep 10
  	done
    
    mne_make_movie \
    --subject ${s} \
    --inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
    --meas  ${s}_${cond}_ave.fif \
    --morph fsaverage \
    --smooth 5 \
    --spm \
    --stc ${s}_${cond}_spm_fsaverage > ${s}_${cond}_spm_fsaverage.log 2>&1 &
	
	done
done



