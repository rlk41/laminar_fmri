#!/bin/bash


echo "************* upscaling EPI.nii ******************************"
echo "requires '$rim file "
echo "outputs as $scaled_rim"

# upsampling script on laynii.com



#module load afni
delta_x=$(3dinfo -di $rim)
delta_y=$(3dinfo -dj $rim)
delta_z=$(3dinfo -dk $rim)
sdelta_x=$(echo "(($delta_x / 4))"|bc -l)
sdelta_y=$(echo "(($delta_x / 4))"|bc -l)
sdelta_z=$(echo "(($delta_z / 4))"|bc -l)
echo "$sdelta_x"
echo "$sdelta_y"
echo "$sdelta_z"
3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode NN -overwrite -prefix $scaled_rim -debug 1 -input $rim
#3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode Li -overwrite -prefix $scaled_EPI -input $EPI






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


