#!/usr/bin/env bash
set -e

#uo pipefail


# rm $VASO_func_dir/sub-*task-movie_run-*_VASO/scripts/IsRunning.lh+rh
# find . -name IsRunning.lh+rh -exec rm {} +
# scancel --name=main_surfL

function fail {
    echo "FAIL: $@" >&2
    exit 1  # signal failure
}

export EPI=$1

# set required paths!
source /home/kleinrl/projects/laminar_fmri/paths_biowulf

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
# export ANAT_bias_2EPI="$(dirname ${ANAT_bias})/$(basename ${ANAT_bias} .nii).$EPI_base.ANAT2EPI.nii"
# export ANAT_bias_2EPI_mgz="$(dirname ${ANAT_bias})/$(basename ${ANAT_bias} .nii).$EPI_base.ANAT2EPI.mgz"

# export seg_wm_2EPI="$(dirname ${seg_wm})/$(basename ${seg_wm} .nii).$EPI_base.ANAT2EPI.nii"
# export seg_wm_2EPI_mgz="$(dirname ${seg_wm})/$(basename ${seg_wm} .nii).$EPI_base.ANAT2EPI.mgz"

# export seg_brain_2EPI="$(dirname ${seg_brain})/$(basename ${seg_brain} .nii).$EPI_base.ANAT2EPI.nii"
# export seg_brain_2EPI_mgz="$(dirname ${seg_brain})/$(basename ${seg_brain} .nii).$EPI_base.ANAT2EPI.mgz"

export subjid=$EPI_base

echo "------------------------------------------"
echo $ANAT_bias_2EPI
echo $seg_wm_2EPI
echo $seg_brain_2EPI
echo "----------------"


# antsApplyTransforms -d 3 -i ${ANAT_bias} -o ${ANAT_bias_2EPI} -r ${ANAT_bias} -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine
# 3dcalc -a ${ANAT_bias_2EPI} -datum short -expr 'a' -prefix ${ANAT_bias_2EPI} -overwrite
# mri_convert ${ANAT_bias_2EPI} ${ANAT_bias_2EPI_mgz}

# antsApplyTransforms -d 3 -i ${seg_wm} -o ${seg_wm_2EPI} -r ${seg_wm} -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine
# 3dcalc -a ${seg_wm_2EPI} -datum short -expr 'a' -prefix ${seg_wm_2EPI} -overwrite
# mri_convert ${seg_wm_2EPI} ${seg_wm_2EPI_mgz}

# antsApplyTransforms -d 3 -i ${seg_brain} -o ${seg_brain_2EPI} -r ${seg_brain} -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine
# 3dcalc -a ${seg_brain_2EPI} -datum short -expr 'a' -prefix ${seg_brain_2EPI} -overwrite
# mri_convert ${seg_brain_2EPI} ${seg_brain_2EPI_mgz}


# #antsApplyTransforms -d 3 -i ${seg_brain} -o ${seg_brain_2EPI} -r ${seg_brain} -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat
# #3dcalc -a ${seg_brain_2EPI} -datum short -expr 'a' -prefix ${seg_brain_2EPI} -overwrite

# #TODO: this should probably just be -autorecon1 not -all
# recon-all -all -hires \
#   -i $ANAT_bias_2EPI \
#   -subjid $subjid \
#   -parallel -openmp 20 \
#   -expert $expert


# # INCLUDE NEW WM AND REGENERATE
# #mv "${SUBJECTS_DIR}/${EPI_base}/mri/wm.mgz" "${SUBJECTS_DIR}/${EPI_base}/mri/wm.backup.mgz"
# cp ${seg_wm_2EPI_mgz} "${SUBJECTS_DIR}/${EPI_base}/mri/wm.mgz"

# # # deosnt work some error 
# # recon-all -autorecon2-wm \
# # -hires \
# #  -s $subjid \
# #  -parallel -openmp 20

# # INCLUDE NEW BRAINMASK AND REGENERATE
# #mv "${SUBJECTS_DIR}/${EPI_base}/mri/brainmask.mgz" "${SUBJECTS_DIR}/${EPI_base}/mri/brainmask.backup.mgz"
# cp ${seg_brain_2EPI_mgz} "${SUBJECTS_DIR}/${EPI_base}/mri/brainmask.mgz"
# cp "${SUBJECTS_DIR}/${EPI_base}/mri/brainmask.mgz" "${SUBJECTS_DIR}/${EPI_base}/mri/brain.mgz"

# echo "running autorecon2-pial"
# recon-all -autorecon-pial \
#  -hires \
#  -s $subjid \
#  -parallel -openmp 20 || fail "running autorecon-pial"

# #  freeview brain.mgz brainmask.mgz wm.mgz aseg.mgz \
# #  ../surf/lh.white ../surf/lh.smoothwm ../surf/lh.pial \
# #  ../surf/rh.white ../surf/rh.smoothwm ../surf/rh.pial 

# # echo "running autorecon2-wm autorecon3"
# # recon-all -autorecon2-wm -autorecon3 \
# #  -hires \
# #  -s $subjid \
# #  -parallel -openmp 20 || fail "running autorecon3"



# # recon-all -autorecon-pial -hires \
# #  -s $subjid \
# #  -parallel -openmp 20


# # TODO: just rerunning autorecon2 - wasn't able to get autorecon2-wm to run
# # double free detected in tchache 2??

# # recon-all -autorecon2 -autorecon3 -hires \
# #   -s $subjid \
# #   -parallel -openmp 40

# # recon-all -autorecon3 -hires \
# #   -s $subjid \
# #   -parallel -openmp 40


# freeview -v mri/T1.mgz \
# -v $EPI_bias \
# -f surf/lh.white:edgecolor=yellow \
# -f surf/lh.pial:edgecolor=red \
# -f surf/rh.white:edgecolor=yellow \
# -f surf/rh.pial:edgecolor=red



#@SUMA_Make_Spec_FS -sid SubjectName -GIFTI
#@SUMA_Make_Spec_FS -sid SubjectName -NIFTI

# '''
# afni -niml &
# suma -spec ../SUMA/SubjectName_both.spec -sv ../SubjectName_SurfVol_Alnd_Exp+orig

# afni -niml &
# suma -spec ../SUMA/SubjectName_both.spec -sv ../SubjectName_SurfVol_Alnd_Exp+orig



# Once SUMA is loaded, press the t key and you will be presented with a nice overlay 
# in AFNI that will allow you to click around in either AFNI or SUMA and see how the 
# cortical surface corresponds to the volume in AFNI.  Check to make sure nothing 
# looks too far out of whack (technical term).

# # Peter Molfese flat maps
# https://afni.nimh.nih.gov/afni/community/board/read.php?1,158211,158226#msg-158226

# '''

#----------------

#EXTRACT LAYERS NO PREPROC 
###################################

hemis=('lh' 'rh')
projfracs=$(seq -w 0 .05 1 )
surf='white'

for hemi in ${hemis[@]}; do
  for projfrac in ${projfracs[@]}; do

    out="${SUBJECTS_DIR}/${EPI_base}/surf/${EPI_base}.${hemi}.projfrac_${projfrac}.${surf}.surf-fwhm-2.vol-fwhm-NA.fsaverage.mgh"

    echo "-----------------------------"
    echo "hemi:      ${hemi}"
    echo "projfrac:  ${projfrac}"
    echo "EPI:       ${EPI_base}"
    echo "OUT:       ${out}"
    echo "-----------------------------"

    mri_vol2surf --src ${EPI} --o ${out} --regheader ${EPI_base} \
    --hemi ${hemi} --surf ${surf} --projfrac ${projfrac} --surf-fwhm 2 \
    --trgsubject fsaverage 

  done
done



# # EXTRACT GSR
# #######################
# hemis=('lh' 'rh')
# projfracs=$(seq -w 0 .05 1 )
# surf='white'

# for hemi in ${hemis[@]}; do
#   for projfrac in ${projfracs[@]}; do

#     out="${SUBJECTS_DIR}/${EPI_base}/surf/${EPI_base}.${hemi}.projfrac_${projfrac}.${surf}.surf-fwhm-2.fsaverage.gsr.mgh"

#     in=$(dirname $EPI)/$(basename $EPI .nii).gsr.nii.gz


#     echo "-----------------------------"
#     echo "hemi:      ${hemi}"
#     echo "projfrac:  ${projfrac}"
#     echo "EPI:       ${EPI_base}"
#     echo "OUT:       ${out}"
#     echo "-----------------------------"

#     mri_vol2surf --src ${in} --o ${out} --regheader ${EPI_base} \
#     --hemi ${hemi} --surf ${surf} --projfrac ${projfrac} --surf-fwhm 2 \
#     --trgsubject fsaverage --fwhm 0 

#   done
# done

#module load python

# EXTRACT COLUMNS ONLY NEED TO RUN ONCE 

# hemis=('lh' 'rh')
# surf='white'
# #column_path=${warp_columns_ev_10000}
# column_path="/data/kleinrl/ds003216/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII/columns_equivol_10000/rim_columns10000.nii"

# for hemi in ${hemis[@]}; do
#     column_base=$(basename $column_path .nii)
#     out="${SUBJECTS_DIR}/sub-01_ses-01_run-01_T1w/surf/${column_base}.${hemi}.${surf}.fsaverage.mgh"
#     #outfile="${SUBJECTS_DIR}/${EPI_base}/surf/${column_base}.${hemi}.${surf}.png"
#     out_srchit="${SUBJECTS_DIR}/sub-01_ses-01_run-01_T1w/surf/${column_base}.${hemi}.${surf}.fsaverage.srchit.nii.gz"
#     echo "-----------------------------"
#     echo "hemi:      ${hemi}"
#     echo "EPI:       ${EPI_base}"
#     echo "OUT:       ${out}"
#     echo "-----------------------------"

#     mri_vol2surf --src ${column_path}  --o ${out} --regheader "sub-01_ses-01_run-01_T1w" \
#     --hemi ${hemi} --surf ${surf} --projfrac-max 0 1 .1 --trgsubject fsaverage --srchit $out_srchit


#     #plot_surf.py --subid $EPI_base --vol $column_path --outfile $outfile
# done




# tksurfer ${EPI_base} lh ${out}
# mri_vol2surf --src sig --src_type bfloat --srcreg register.dat --hemi lh --o ./sig-lh.w --out_type paint --float2int tkregister --frame 2




# read the surfaces in for analysis
