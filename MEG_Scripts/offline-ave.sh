#!/bin/bash
cwd=$(pwd)

for s in  10896 10910 10911; do

#The first step is to create average waveforms for all conditions, 
#regardless of condition. 
#This one will be used to project raw data onto the surface
cd ${cwd}/${s}/MEG/

mne_process_raw \
--raw ${cwd}/${s}/MEG/${s}_anti_run1_dn_ds_sss_raw.fif \
--raw ${cwd}/${s}/MEG/${s}_anti_run2_dn_ds_sss_raw.fif \
--raw ${cwd}/${s}/MEG/${s}_anti_run3_dn_ds_sss_raw.fif \
--raw ${cwd}/${s}/MEG/${s}_anti_run4_dn_ds_sss_raw.fif \
--raw ${cwd}/${s}/MEG/${s}_anti_run5_dn_ds_sss_raw.fif \
--raw ${cwd}/${s}/MEG/${s}_anti_run6_dn_ds_sss_raw.fif \
--raw ${cwd}/${s}/MEG/${s}_anti_run7_dn_ds_sss_raw.fif \
--raw ${cwd}/${s}/MEG/${s}_anti_run8_dn_ds_sss_raw.fif \
--lowpass 80 --highpass 1 \
--projon \
--ave ~/bin/Scripts/MEG_Scripts/anti_vgs-All.ave \
--gave ${s}_anti_vgs_all_ave.fif > ${s}_anti_vgs_all_ave.log 2>&1 &

while [`jobs | wc -l` -ge 16 ]
  	do
    		sleep 10
done

#then do each condition separately
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
	--events ${s}_${cond}-run1-All.eve \
	--events ${s}_${cond}-run2-All.eve \
	--events ${s}_${cond}-run3-All.eve \
	--events ${s}_${cond}-run4-All.eve \
	--events ${s}_${cond}-run5-All.eve \
	--events ${s}_${cond}-run6-All.eve \
	--events ${s}_${cond}-run7-All.eve \
	--events ${s}_${cond}-run8-All.eve \
	--lowpass 80 --highpass 1 \
	--projon \
	--ave ~/bin/Scripts/MEG_Scripts/${cond}-All.ave \
	--gave ${s}_${cond}_all_ave.fif > ${s}_${cond}_all_ave.log 2>&1 &
	
	while [`jobs | wc -l` -ge 16 ]
  	do
    		sleep 10
  	done
	
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
	--events ${s}_${cond}-run1-Correct.eve \
	--events ${s}_${cond}-run2-Correct.eve \
	--events ${s}_${cond}-run3-Correct.eve \
	--events ${s}_${cond}-run4-Correct.eve \
	--events ${s}_${cond}-run5-Correct.eve \
	--events ${s}_${cond}-run6-Correct.eve \
	--events ${s}_${cond}-run7-Correct.eve \
	--events ${s}_${cond}-run8-Correct.eve \
	--lowpass 80 --highpass 1 \
	--projon \
	--ave ~/bin/Scripts/MEG_Scripts/${cond}-Correct.ave \
	--gave ${s}_${cond}_Correct_ave.fif > ${s}_${cond}_Correct_ave.log 2>&1 &
	
	while [`jobs | wc -l` -ge 16 ]
  	do
    		sleep 10
  	done
	
done
done