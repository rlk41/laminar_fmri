
cd /media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandetinni/ds003216-download/derivatives/sub-01/average_across_days

fslmaths VASO_LN_across_days.nii -Tmean VASO_LN_across_days_tmean.nii


N4BiasFieldCorrection -d 3 -i VASO_LN_across_days_tmean.nii.gz \
	-o VASO_LN_across_days_tmean_ihc.nii.gz





