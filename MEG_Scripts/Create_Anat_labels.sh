#!/bin/bash

for s in 10901  10902   10894   10911   10910   10892   10908   10920   10915   10918   10923   10931   10912   10927   10896   10939   10917   10951   10938;  do
	cd $SUBJECTS_DIR/${s}/label
	mne_annot2labels --subject ${s} --parc aparc.a2009s
	mkdir /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/
	
	cp S_intrapariet_and_P_trans-rh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/IPS-rh.label
	cp S_intrapariet_and_P_trans-lh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/IPS-lh.label
	cp S_front_middle-rh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/MFG-rh.label
	cp S_front_middle-lh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/MFG-lh.label
	cp S_precentral-inf-part-rh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/iFEF-rh.label
	cp S_precentral-inf-part-lh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/iFEF-lh.label
	cp S_precentral-sup-part-rh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/sFEF-rh.label
	cp S_precentral-sup-part-lh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/sFEF-lh.label
	cp S_front_inf-rh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/IFG-rh.label
	cp S_front_inf-lh.label /Volumes/T800/Multimodal/ANTI/${s}/MEG/labels/IFG-lh.label
done