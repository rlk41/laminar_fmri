#!/bin/bash 



echo "Running spm_bias_field_correction on ${EPI}"
spm_bias_field_correct -i ${EPI};

# THIS SHOUDL ALREADY BE COMPLETED in main_ANAT.sh
# RUNNING BIAS CORECTION ON ANAT output is ANAT_bias
#echo "Running spm_bias_field_correction on ${ANAT}"
#spm_bias_field_correct -i ${ANAT};


#freeview ${ANAT_bias} ${EPI_bias}


mkdir ${ANTs_dir}

#itksnap -g ${EPI_bias} -o ${ANAT_bias}  --scale 1

# READ THIS: https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/
# right click small images -> click "display as overlay"
# right click layer -> "auto-adjust contrast"
# tools > registration -> manual (click between using "w" key, and adjust)
# once you have good fit go to automatic tab use params:
#     Affine, Mutual Information, check "use segmentation as mask" coarse 4x, finest 2x
# might want to save the manually adjusted xfm before applying automatic.
# save in ...working_ANTs as initial_matrix.txt
# if the automatic looks good, save as "initial_matrix.txt" (overwrite the backup)


echo "RUNNING: run_ANTS this will calculate the xfm from ANAT to EPI_mean and"
echo "and apply the xfm producing warped_MP2RAGE.nii"
echo "'warp_ANTS_resampleNN.sh <input_nii> <master_file>' will "
echo "apply this xfm using nearestneighbor so only use with parcs"

echo ${EPI_bias}
echo ${ANAT_bias}
# REQUIRES: initial_matrix.txt (in working_ANTs), EPI_bias, ANAT_bias
# todo: i need to include initial_matrix.txt in git
run_ANTs -e ${EPI_bias} -a ${ANAT_bias}
