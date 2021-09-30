#!/bin/bash 

in=$1

out_dir=$(dirname $in)
out_base=$(basename $in .nii)
out_base=$(basename $out_base .nii.gz)
out_base=$(basename $out_base .mgz)
out_base=$out_base'.resample2scaledEPI.nii'
out_filepath=$out_dir/$out_base


echo "     "
echo "upsampling: $(basename $in)"
echo "      "
echo "master:     $(basename $scaled_EPI)"
echo "     "
echo "out_base:    $out_base"
echo "      "
echo "out_filepath: $out_filepath"



3dresample -master $scaled_EPI -rmode NN -overwrite -prefix $out_filepath -input $in

