

dir=$1
rois
for roi in $dir/*.nii; do
  fslmaths $roi -b $parc $out