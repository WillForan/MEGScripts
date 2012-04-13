#!/bin/bash
cwd=$(pwd)

for s in 10951 10938; do
	for n in 1 2 3 4 5 6 7 8; do
		
		while [`jobs | wc -l` -ge 16 ]
  		do
    		sleep 10
  		done
		
		mne_process_raw --raw ${cwd}/${s}/MEG/${s}_anti_run${n}_raw_sss.fif --highpass 1 --lowpass 80 --eoghighpass 1 --eoglowpass 40 --decim 4 --save ${cwd}/${s}/MEG/${s}_anti_run${n}_ds_sss --projon > ${cwd}/${s}/MEG/${s}_mne_process_run${n}.log 2>&1 &	
	done

	while [`jobs | wc -l` -ge 16 ]
  	do
    	sleep 10
  	done

	mne_process_raw --raw ${cwd}/${s}/MEG/${s}_calib_raw.fif --highpass 1 --lowpass 80 --eoghighpass 1 --eoglowpass 40 --decim 4 --save ${cwd}/${s}/MEG/${s}_calib_ds --projon > ${cwd}/${s}/MEG/${s}_mne_process_calib.log 2>&1 &
	
done