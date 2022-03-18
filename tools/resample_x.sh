#!/bin/bash

echo "************* upscaling EPI.nii ******************************"
#echo "requires '$EPI file "
#echo "outputs as $scaled_EPI"

# upsampling script on laynii.com

IN=$1

X=$2 

OUT_base=$(basename $IN .nii)
OUT_base=$(basename $OUT_base .nii.gz)

OUT="$(dirname $IN)/$OUT_base.scaled${X}x.nii.gz"

echo "IN:   $IN"
echo "OUT:  $OUT"

#module load afni
delta_x=$(3dinfo -adi $IN)
delta_y=$(3dinfo -adj $IN)
delta_z=$(3dinfo -adk $IN)
sdelta_x=$(echo "(($delta_x / $X))"|bc -l)
sdelta_y=$(echo "(($delta_x / $X))"|bc -l)
sdelta_z=$(echo "(($delta_z / $X))"|bc -l)
echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"
3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Cu -overwrite -prefix $OUT -debug 1 -input $IN






# echo "************* upscaling EPI.nii ******************************"
# echo "requires 'EPI.nii file "
# echo "outputs as scaled_EPI.nii"

# # upsampling script on laynii.com



# #module load afni
# delta_x=$(3dinfo -di EPI.nii)
# delta_y=$(3dinfo -dj EPI.nii)
# delta_z=$(3dinfo -dk EPI.nii)
# sdelta_x=$(echo "(($delta_x / 4))"|bc -l)
# sdelta_y=$(echo "(($delta_x / 4))"|bc -l)
# sdelta_z=$(echo "(($delta_z / 4))"|bc -l)
# echo "$sdelta_x"
# echo "$sdelta_y"
# echo "$sdelta_z"
# 3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite -prefix scaled_EPI.nii -input EPI.nii


