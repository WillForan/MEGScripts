#!/bin/bash
cwd=$(pwd)

for s in  10896 10910 10911; do	
		while [`jobs | wc -l` -ge 16 ]
  		do
    			sleep 10
  		done
  		
		cd ${cwd}/${s}/MEG/
		
		#do forward solution
		mne_do_forward_solution --src ${s}-7-src.fif \
		--megonly --mindist 5 --overwrite \
		--meas ${s}_anti_vgs_all_ave.fif \
		--fwd ${s}_anti_vgs_all_fwd.fif \
		--subject ${s} > ${s}_fwd.log
		
		# do inverse solution
		mne_do_inverse_operator --fwd ${s}_anti_vgs_all_fwd.fif \
		--depth --loose 0.2 --meg --senscov ${s}_anti_cov.fif \
		--subject ${s} > ${s}_inv.log
		
done