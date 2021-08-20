#!/usr/bin/env bash
set -euo pipefail



source ../paths


# RUNNING BIAS CORRECTION ON EPI output EPI_bias
# REQUIRES:  EPI (original), spm_path, tools_dir added to PATH
#echo "Running spm_bias_field_correction on ${EPI}"
#spm_bias_field_correct -i ${EPI};

# RUNNING BIAS CORECTION ON ANAT output is ANAT_bias
#echo "Running spm_bias_field_correction on ${ANAT}"
#spm_bias_field_correct -i ${ANAT};

#freeview ${ANAT_bias} ${EPI_bias}


#mkdir ${ANTs_dir}

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


#freeview ${EPI_bias} ${ANAT_warped}

#mkdir $SUBJECTS_DIR
#cp $tools_dir/expert.opts $expert
#cp $tools_dir/FreeSurferColorLUT.txt $LUT
#cp $tools_dir/HCPMMP1_LUT_ordered_RS.txt $SUBJECTS_DIR
#cp $tools_dir/HCPMMP1_LUT_original_RS.txt $SUBJECTS_DIR


############################
# get ANAT_bias in EPI_space
# get seg_wm in EPI_space
# get seg_brain in EPI_space

#TODO: move to EPI specific DIR
export ANAT_bias_2EPI="$(dirname ${ANAT_bias})/$(basename ${ANAT_bias} .nii).ANAT2EPI.nii"
export ANAT_bias_2EPI_mgz="$(dirname ${ANAT_bias})/$(basename ${ANAT_bias} .nii).ANAT2EPI.mgz"

export seg_wm_2EPI="$(dirname ${seg_wm})/$(basename ${seg_wm} .nii).ANAT2EPI.nii"
export seg_wm_2EPI_mgz="$(dirname ${seg_wm})/$(basename ${seg_wm} .nii).ANAT2EPI.mgz"

export seg_brain_2EPI="$(dirname ${seg_brain})/$(basename ${seg_brain} .nii).ANAT2EPI.nii"
export seg_brain_2EPI_mgz="$(dirname ${seg_brain})/$(basename ${seg_brain} .nii).ANAT2EPI.mgz"

export subjid=$EPI_base

echo "------------------------------------------"
echo $ANAT_bias_2EPI
echo $seg_wm_2EPI
echo $seg_brain_2EPI
echo "----------------"

antsApplyTransforms -d 3 -i ${ANAT_bias} -o ${ANAT_bias_2EPI} -r ${ANAT_bias} -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine
3dcalc -a ${ANAT_bias_2EPI} -datum short -expr 'a' -prefix ${ANAT_bias_2EPI} -overwrite
mri_convert ${ANAT_bias_2EPI} ${ANAT_bias_2EPI_mgz}

antsApplyTransforms -d 3 -i ${seg_wm} -o ${seg_wm_2EPI} -r ${seg_wm} -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine
3dcalc -a ${seg_wm_2EPI} -datum short -expr 'a' -prefix ${seg_wm_2EPI} -overwrite
mri_convert ${seg_wm_2EPI} ${seg_wm_2EPI_mgz}

antsApplyTransforms -d 3 -i ${seg_brain} -o ${seg_brain_2EPI} -r ${seg_brain} -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine
3dcalc -a ${seg_brain_2EPI} -datum short -expr 'a' -prefix ${seg_brain_2EPI} -overwrite
mri_convert ${seg_brain_2EPI} ${seg_brain_2EPI_mgz}


#antsApplyTransforms -d 3 -i ${seg_brain} -o ${seg_brain_2EPI} -r ${seg_brain} -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
#3dcalc -a ${seg_brain_2EPI} -datum short -expr 'a' -prefix ${seg_brain_2EPI} -overwrite

#TODO: this should probably just be -autorecon1 not -all
recon-all -all -hires \
  -i $ANAT_bias_2EPI \
  -subjid $subjid \
  -parallel -openmp 40 \
  -expert $expert


# INCLUDE NEW WM AND REGENERATE
mv "${SUBJECTS_DIR}/${EPI_base}/mri/wm.mgz" "${SUBJECTS_DIR}/${EPI_base}/mri/wm.backup.mgz"
cp ${seg_wm_2EPI_mgz} "${SUBJECTS_DIR}/${EPI_base}/mri/wm.mgz"

#recon-all -autorecon-wm -hires \
#  -s $subjid \
#  -parallel -openmp 40

# INCLUDE NEW BRAINMASK AND REGENERATE
mv "${SUBJECTS_DIR}/${EPI_base}/mri/brainmask.mgz" "${SUBJECTS_DIR}/${EPI_base}/mri/brainmask.backup.mgz"
cp ${seg_brain_2EPI_mgz} "${SUBJECTS_DIR}/${EPI_base}/mri/brainmask.mgz"

#recon-all -autorecon-pial -hires \
#  -s $subjid \
#  -parallel -openmp 40


# TODO: just rerunning autorecon2 - wasn't able to get autorecon2-wm to run
# double free detected in tchache 2??

recon-all -autorecon2 -hires \
  -s $subjid \
  -parallel -openmp 40

recon-all -autorecon3 -hires \
  -s $subjid \
  -parallel -openmp 40

<<comment

freeview -v mri/T1.mgz \
-f surf/lh.white:edgecolor=yellow \
-f surf/lh.pial:edgecolor=red \
-f surf/rh.white:edgecolor=yellow \
-f surf/rh.pial:edgecolor=red

comment


hemis=('lh' 'rh')
projfracs=$(seq 0 .1 1 )
surf='white'

for hemi in ${hemis[@]}; do
  for projfrac in ${projfracs[@]}; do
    out="${SUBJECTS_DIR}/${EPI_base}/surf/${EPI_base}.${hemi}.projfrac_${projfrac}.${surf}.mgh"

    echo "-----------------------------"
    echo "hemi:      ${hemi}"
    echo "projfrac:  ${projfrac}"
    echo "EPI:       ${EPI_base}"
    echo "OUT:       ${out}"
    echo "-----------------------------"

    mri_vol2surf --src ${EPI} --o ${out} --regheader ${EPI_base} --hemi ${hemi} --surf ${surf} --projfrac ${projfrac} --surf-fwhm 2
  done
done


