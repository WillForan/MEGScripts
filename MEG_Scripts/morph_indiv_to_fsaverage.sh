#!/bin/bash

echo $SUBJECTS_DIR

for s in 10896 10910 10911;  do
	mne_make_morph_maps --from ${s} --to fsaverage --redo
done