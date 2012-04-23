
for s in 10941 ; do

	while [`jobs | wc -l` -ge 12 ]
  	do
    		sleep 10
  	done
	
	cd $SUBJECTS_DIR
	make_mne_model.sh ${s} > $SUBJECTS_DIR/${s}/scripts/${s}_make_mne_model.log 2>&1 &	

done
