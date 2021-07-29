#1/bin/bash

#f="$layer4EPI/hcp-mmp-b.nii.gz"
f=$1
resample_master=$2

f_base=$(basename $f .nii)
f_out="warped_${f_base}.nii"

rs_base=$(basename $resample_master .nii)
f_out_rs="warped_${f_base}.resample2${rs_base}.nii"

echo "Applying ANTS xfm ${ANTs_reg_1warp}"
echo "converting to short to save space "
echo "resamplign to ${resample_master}"
echo "outputs: ${f_out}"
echo "         ${f_out_rs}"
echo "       "
antsApplyTransforms -d 3 -i $f -o $f_out -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor
3dcalc -a $f_out -datum short -expr 'a' -prefix $f_out -overwrite
3dresample -master $resample_master -rmode NN -overwrite -prefix $f_out_rs  -input $f_out