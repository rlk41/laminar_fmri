ds_dir='/media/richard/bfb1e328-6d97-4280-8331-5daeb988f70a/bandettini/ds003216-download'
VASO_func_dir="${ds_dir}/derivatives/sub-01/VASO_func"


export ANAT_base="sub-01_ses-01_run-01_T1w"
export ANAT="${ds_dir}/sub-01/ses-01/anat/${ANAT_base}.nii"
export ANAT_bias="${ds_dir}/sub-01/ses-01/anat/${ANAT_base}.bias.nii"

for EPI in ${VASO_func_dir}/*VASO.nii; do

  EPI_base="${VASO_func_dir}/$(basename ${EPI} .nii)"
  EPI_bias="${EPI_base}_working_bias/muncorr.nii" # need to change this to 'export EPI_bias="${EPI_base}.bias.nii" '
  ANTs_dir="${EPI_base}_working_ANTs"

  mkdir ${ANTs_dir}

  #itksnap -g ${EPI_bias} -o ${ANAT_bias}  --scale 1
done


# READ THIS: https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/
# right click small images -> click "display as overlay"
# right click layer -> "auto-adjust contrast"
# tools > registration -> manual (click between using "w" key, and adjust)
# once you have good fit go to automatic tab use params:
#     Affine, Mutual Information, check "use segmentation as mask" coarse 4x, finest 2x
# might want to save the manually adjusted xfm before applying automatic.
# save in ...working_ANTs as initial_matrix.txt
# if the automatic looks good, save as "initial_matrix.txt" (overwrite the backup)
