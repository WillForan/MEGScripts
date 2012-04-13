#!/bin/bash
cwd=$(pwd)

# note including all trials for covariance matrix. Need enough tirals
for s in $1;  do

	#setup source space
	mne_setup_source_space --subject $1 --spacing 5 --overwrite 
	mne_setup_forward_model --subject $1 --surf --ico 4 --homog
	
	cd ${cwd}/${s}/MEG/
		
	#calculate noise covariance (or use empty room?)
	mne_process_raw \
	--raw ${cwd}/${s}/MEG/${s}_anti_run1_dn_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run2_dn_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run3_dn_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run4_dn_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run5_dn_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run6_dn_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run7_dn_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run8_dn_ds_sss_raw.fif \
	--events ${cwd}/${s}/MEG/${s}_all-run1-All.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run2-All.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run3-All.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run4-All.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run5-All.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run6-All.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run7-All.eve \
	--events ${cwd}/${s}/MEG/${s}_all-run8-All.eve \
	--lowpass 80 --highpass 1 \
	--projon \
	--digtrig STI101 \
	--cov ~/bin/Scripts/MEG_Scripts/anti.cov \
	--gcov ${s}_anti_cov.fif
	
	
	#do offline averaging for each condition
	for cond in anti vgs all; do
	
	# all trials (both correct and incorrect)
		mne_process_raw \
		--raw ${cwd}/${s}/MEG/${s}_anti_run1_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run2_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run3_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run4_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run5_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run6_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run7_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run8_dn_ds_sss_raw.fif \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run1-All.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run2-All.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run3-All.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run4-All.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run5-All.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run6-All.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run7-All.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run8-All.eve \
		--lowpass 80 --highpass 1 \
		--projon \
		--ave ~/bin/Scripts/MEG_Scripts/${cond}-All.ave \
		--gave ${s}_${cond}_all_ave.fif 
	
		#only correct trials
		mne_process_raw \
		--raw ${cwd}/${s}/MEG/${s}_anti_run1_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run2_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run3_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run4_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run5_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run6_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run7_dn_ds_sss_raw.fif \
		--raw ${cwd}/${s}/MEG/${s}_anti_run8_dn_ds_sss_raw.fif \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run1-Correct.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run2-Correct.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run3-Correct.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run4-Correct.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run5-Correct.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run6-Correct.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run7-Correct.eve \
		--events ${cwd}/${s}/MEG/${s}_${cond}-run8-Correct.eve \
		--lowpass 80 --highpass 1 \
		--projon \
		--ave ~/bin/Scripts/MEG_Scripts/${cond}-Correct.ave \
		--gave ${s}_${cond}_Correct_ave.fif 
	
	done
	
	
	#do forward solution
	mne_do_forward_solution --src ${s}-5-src.fif \
	--megonly --mindist 5 --overwrite \
	--meas ${s}_all_all_ave.fif \
	--fwd ${s}_anti_vgs_all_fwd.fif \
	--subject ${s}
		
	# do inverse solution
	mne_do_inverse_operator --fwd ${s}_anti_vgs_all_fwd.fif \
	--depth --loose 0.2 --meg --senscov ${s}_anti_cov.fif \
	--subject ${s}
	
	#morph maps
	mne_make_morph_maps --from ${s} --to fsaverage --redo
	
	
	#create STC files of current estimates in averaged surface
	#for cond in anti_Correct anti_all vgs_Correct vgs_all all_Correct all_all; do
	for cond in anti_Correct anti_all vgs_Correct vgs_all all_Correct all_all; do
		mne_make_movie \
		--subject ${s} \
		--inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--meas ${s}_${cond}_ave.fif \
		--morph fsaverage \
		--smooth 5 \
		--stc ${s}_${cond}_fsaverage
		
		mne_make_movie \
		--subject ${s} \
		--inv ${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--meas  ${s}_${cond}_ave.fif \
		--morph fsaverage \
		--smooth 5 \
		--spm \
		--stc ${s}_${cond}_spm_fsaverage
	done
	
done