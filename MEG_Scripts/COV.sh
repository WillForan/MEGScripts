#!/bin/bash
cwd=$(pwd)

# note including all trials for covariance matrix. Need enough tirals
for s in 10896 10910 10911;  do
	cd ${cwd}/${s}/MEG/
		
	#calculate noise covariance (or use empty room?)
	mne_process_raw \
	--raw ${cwd}/${s}/MEG/${s}_anti_run1_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run2_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run3_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run4_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run5_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run6_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run7_ds_sss_raw.fif \
	--raw ${cwd}/${s}/MEG/${s}_anti_run8_ds_sss_raw.fif \
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
	--gcov ${s}_anti_cov.fif > ${s}_anti_cov.log 2>&1 &
	
	while [`jobs | wc -l` -ge 8 ]
  		do
    		sleep 10
  	done
	
done