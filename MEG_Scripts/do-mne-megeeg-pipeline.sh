#!/bin/bash
cwd=$(pwd)
export SUBJECTS_DIR=/home/hwangk/Luna1/dataFromDisks/RespMon12C/subjects
# note including all trials for covariance matrix. Need enough tirals
for s in $1;  do
	cd ${cwd}/${s}/SSS/
		
	#calculate noise covariance (or use empty room?)
	mne_process_raw \
	--raw ${cwd}/${s}/SSS/${s}_prep_run1_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run2_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run3_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run4_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run5_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run6_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run7_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run8_dn_sss_raw.fif \
	--events ${cwd}/${s}/SSS/${s}_01_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_02_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_03_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_04_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_05_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_06_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_07_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_08_prep_ave.lst \
	--lowpass 80 --highpass 1 \
	--projon \
	--cov ${cwd}/prep.cov \
	--gcov ${s}_prep_cov.fif
	
	
	#do offline averaging
	mne_process_raw \
	--raw ${cwd}/${s}/SSS/${s}_prep_run1_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run2_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run3_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run4_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run5_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run6_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run7_dn_sss_raw.fif \
	--raw ${cwd}/${s}/SSS/${s}_prep_run8_dn_sss_raw.fif \
	--events ${cwd}/${s}/SSS/${s}_01_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_02_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_03_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_04_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_05_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_06_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_07_prep_ave.lst \
	--events ${cwd}/${s}/SSS/${s}_08_prep_ave.lst \
	--lowpass 80 --highpass 1 \
	--projon \
	--ave ${cwd}/prep.ave \
	--gave ${s}_prep_ave.fif 


	#do forward solution
	for r in 1 2 3 4 5 6 7 8; do
		mne_do_forward_solution --overwrite \
		--meas ${s}_prep_run${r}_dn_sss_raw.fif --subject ${s} --fwd ${s}_prep_run${r}_fwd.fif --meg --eeg \
		--bem $SUBJECTS_DIR/${s}/bem/${s}-5120-5120-5120-bem-sol.fif
		mne_do_forward_solution --overwrite \
		--meas ${s}_prep_run${r}_dn_sss_raw.fif --subject ${s} --fwd ${s}_prep_meg_run${r}_fwd.fif --meg \
		--bem $SUBJECTS_DIR/${s}/bem/${s}-5120-5120-5120-bem-sol.fif
	done
	
	#average forward solution
	mne_average_forward_solutions \
	--fwd ${s}_prep_run1_fwd.fif \
	--fwd ${s}_prep_run2_fwd.fif \
	--fwd ${s}_prep_run3_fwd.fif \
	--fwd ${s}_prep_run4_fwd.fif \
	--fwd ${s}_prep_run5_fwd.fif \
	--fwd ${s}_prep_run6_fwd.fif \
	--fwd ${s}_prep_run7_fwd.fif \
	--fwd ${s}_prep_run8_fwd.fif \
	--out ${s}_prep_fwd.fif
	
	mne_average_forward_solutions \
	--fwd ${s}_prep_meg_run1_fwd.fif \
	--fwd ${s}_prep_meg_run2_fwd.fif \
	--fwd ${s}_prep_meg_run3_fwd.fif \
	--fwd ${s}_prep_meg_run4_fwd.fif \
	--fwd ${s}_prep_meg_run5_fwd.fif \
	--fwd ${s}_prep_meg_run6_fwd.fif \
	--fwd ${s}_prep_meg_run7_fwd.fif \
	--fwd ${s}_prep_meg_run8_fwd.fif \
	--out ${s}_prep_meg_fwd.fif
	
	# do inverse solution, use Yigal's averaged forward solution
	mne_do_inverse_operator --fwd ${s}_prep_fwd.fif \
	--depth --loose 0.2 --meg --eeg --senscov ${s}_prep_cov.fif \
	--subject ${s} --inv ${s}_prep_inv.fif
	
	mne_do_inverse_operator --fwd ${s}_prep_meg_fwd.fif \
	--depth --loose 0.2 --meg --senscov ${s}_prep_cov.fif \
	--subject ${s} --inv ${s}_prep_meg_inv.fif
	
	#morph maps
	mne_make_morph_maps --from ${s} --to fsaverage --redo
	
	
	#create STC files of current estimates in averaged surface

	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 1 \
	--stc ${s}_Hard_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 2 \
	--stc ${s}_Easy_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 3 \
	--stc ${s}_fake_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 4 \
	--stc ${s}_Error_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 1 \
	--spm \
	--stc ${s}_Hard_spm_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 2 \
	--spm \
	--stc ${s}_Easy_spm_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 3 \
	--spm \
	--stc ${s}_fake_spm_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 4 \
	--spm \
	--stc ${s}_Error_spm_fsaverage
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 1 \
	--stc ${s}_Hard_fsaverage_meg
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 2 \
	--stc ${s}_Easy_fsaverage_meg
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 3 \
	--stc ${s}_fake_fsaverage_meg
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 4 \
	--stc ${s}_Error_fsaverage_meg
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 1 \
	--spm \
	--stc ${s}_Hard_spm_fsaverage_meg
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 2 \
	--spm \
	--stc ${s}_Easy_spm_fsaverage_meg
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 3 \
	--spm \
	--stc ${s}_fake_spm_fsaverage_meg
	
	mne_make_movie \
	--subject ${s} \
	--inv ${s}_prep_meg_inv.fif \
	--meas ${s}_prep_ave.fif \
	--morph fsaverage \
	--smooth 5 \
	--set 4 \
	--spm \
	--stc ${s}_Error_spm_fsaverage_meg

done
