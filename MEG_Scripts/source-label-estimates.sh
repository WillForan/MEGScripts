#!/bin/bash
cwd=$(pwd)

for s in 10901	10902	10894	10911	10910	10892	10920	10915	10918	10923	10931	10912	10927	10896	10939	10917	10951	10938; do	
	for rn in 1 2 3 4 5 6 7 8; do
		
		while [`jobs | wc -l` -ge 16 ]
  		do
    		sleep 10
  		done
		
		# project source estimates, for each label
		mne_compute_raw_inverse --in ${cwd}/${s}/MEG/${s}_anti_run${rn}_dn_ds_sss_raw.fif \
		--inv ${cwd}/${s}/MEG/${s}_anti_vgs_all_fwd.fif-meg-inv.fif \
		--picknormalcomp \
		--align_z \
		--labeldir ${cwd}/${s}/MEG/Labels \
		--orignames \
		--digtrig STI101 \
		--out ${cwd}/Source_Estimates/${s}_anti_run${rn}_label_source > ${cwd}/Source_Estimates/${s}_anti_run${rn}_label_source.log 2>&1 &
	
	done
done
