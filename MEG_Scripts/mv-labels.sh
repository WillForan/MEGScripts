
for s in 10613 ; do

	cd ${s}
	
	cp ~/Subjects/${s}/label/S_precentral-sup-part-lh.label ./FEF-lh.label
	cp ~/Subjects/${s}/label/S_intrapariet_and_P_trans-lh.label ./IPS-lh.label
	cp ~/Subjects/${s}/label/S_front_inf-lh.label ./IFG-lh.label
	cp ~/Subjects/${s}/label/S_front_middle-lh.label ./MFG-lh.label
	cp ~/Subjects/${s}/label/G_and_S_cingul-Mid-Ant-lh.label ./ACC-lh.label
	cp ~/Subjects/${s}/label/G_and_S_cingul-Mid-Post-lh.label ./SEF-lh.label
	cp ~/Subjects/${s}/label/S_calcarine-lh.label ./VC-lh.label
	
	cp ~/Subjects/${s}/label/S_precentral-sup-part-rh.label ./FEF-rh.label
	cp ~/Subjects/${s}/label/S_intrapariet_and_P_trans-rh.label ./IPS-rh.label
	cp ~/Subjects/${s}/label/S_front_inf-rh.label ./IFG-rh.label
	cp ~/Subjects/${s}/label/S_front_middle-rh.label ./MFG-rh.label
	cp ~/Subjects/${s}/label/G_and_S_cingul-Mid-Ant-rh.label ./ACC-rh.label
	cp ~/Subjects/${s}/label/G_and_S_cingul-Mid-Post-rh.label ./SEF-rh.label
	cp ~/Subjects/${s}/label/S_calcarine-rh.label ./VC-rh.label
	cd ..

done