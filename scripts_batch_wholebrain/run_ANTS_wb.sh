#!/bin/bash
set -e 


# sbatch --mem=20g --cpus-per-task=50 \
# --output="$logs/ANTS_wholebrain.log" \
# --time 72:00:00 \
# --job-name="ANTs_wb" \
# "$scripts_batch_dir/run_ANTS_wb.sh"




source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0



#mkdir -p ${ANTs_dir}
#cp $ds_dir/ANAT2VASO_LN.MEAN.txt $xfm_auto

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


#echo "RUNNING: run_ANTS this will calculate the xfm from ANAT to EPI_mean"
#echo ${EPI_bias}
#echo ${ANAT_bias}
# REQUIRES: initial_matrix.txt (in working_ANTs), EPI_bias, ANAT_bias
# ANTs might benefit from background noise removal...
#run_ANTs -e ${EPI_bias} -a ${ANAT_bias}

cd $ANTs_dir
run_ANTs -e ${EPI_mean_all_bias} -a ${ANAT_bias}
