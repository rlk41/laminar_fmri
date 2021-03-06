#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

# set required paths!
source ../paths


# RUNNING BIAS CORRECTION ON EPI output EPI_bias
# REQUIRES:  EPI (original), spm_path, tools_dir added to PATH
#echo "Running spm_bias_field_correction on ${EPI}"
#spm_bias_field_correct -i ${EPI};

# RUNNING BIAS CORECTION ON ANAT output is ANAT_bias
echo "Running spm_bias_field_correction on ${ANAT}"
spm_bias_field_correct -i ${ANAT};

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


#echo "RUNNING: run_ANTS this will calculate the xfm from ANAT to EPI_mean"
#echo ${EPI_bias}
#echo ${ANAT_bias}
# REQUIRES: initial_matrix.txt (in working_ANTs), EPI_bias, ANAT_bias
# ANTs might benefit from background noise removal...
#run_ANTs -e ${EPI_bias} -a ${ANAT_bias}


#freeview ${EPI_bias} ${ANAT_warped}

mkdir $SUBJECTS_DIR
cp $tools_dir/expert.opts $expert
cp $tools_dir/FreeSurferColorLUT.txt $LUT
cp $tools_dir/HCPMMP1_LUT_ordered_RS.txt $SUBJECTS_DIR
cp $tools_dir/HCPMMP1_LUT_original_RS.txt $SUBJECTS_DIR


recon-all -all -hires \
  -i $ANAT_bias \
  -subjid $subjid \
  -parallel -openmp 40 \
  -expert $expert

# MANUAL EDITS - BRAINMASK

# 1) Use SPM's C1,C2 segmentations to brainextract.
# 2) Use Freesurfers gcuts to remove any dura/extra
# 3) manual edits using freeview recon edit mode
# reference -- 01_registration_vaso.sh

# 1) combine c1uncorr.nii and c2uncorr.nii
3dcalc -a "$ANAT_bias_dir/c1uncorr.nii" \
-b "$ANAT_bias_dir/c2uncorr.nii" \
-expr '(a+b)' \
-prefix "$ANAT_bias_dir/c12uncorr.nii"

# mri_mask [options] <in vol> <mask vol> <out vol>
mri_mask "$recon_dir/mri/brainmask.mgz" \
"$ANAT_bias_dir/c12uncorr.nii" \
"$recon_dir/mri/brainmask.manualedit.nii"

# 2) use mri_gcut to try to get rid of dura
mri_gcut -110 "$recon_dir/mri/brainmask.manualedit.nii" \
"$recon_dir/mri/brainmask.manualedit2.nii"

#3 manualedits
# freeview -> recon edit -> shift left click to erase voxels outside brain (Dura,etc.)-> save as brainmask.manualedit#.mgz

mv "$recon_dir/mri/brainmask.mgz" "$recon_dir/mri/brainmask.backup.mgz"
cp brainmask.manualedit2.mgz brainmask.mgz

recon-all -autorecon2 -hires \
  -s $subjid \
  -parallel -openmp 40

recon-all -autorecon3 -hires \
  -s $subjid \
  -parallel -openmp 40



# MIGHT NEED TO PLAY AROUND WHEN RERUNNING RECON-ALL "-autorecon2..3"
# THIS LINK DESCRIBES WHAT YOU NEED TO RERUN DEPENDING UPON THE FILES YOU EDIT
# https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all#Manual-InterventionWorkflowDirectives

## remake using the new brainmask.mgz
#recon-all -make all -hires\
#  -s  $subjid \
#  -parallel -openmp 40









#################################################
### SUMA - RENZO'S CODE TO BUILD SURFACES FOR RIM.NII
###################################################


# THIS WILL MAKE THE SURFACES, {LH,RH}.WHITE ETC..
mris_make_surfaces $subjid rh
mris_make_surfaces $subjid lh

# VISUALIZE
freeview -v mri/T1.mgz \
-f surf/lh.white:edgecolor=yellow \
-f surf/lh.pial:edgecolor=red \
-f surf/rh.white:edgecolor=yellow \
-f surf/rh.pial:edgecolor=red

cd $recon_dir

# SUMA, build meshes, build rim
# input: recon-all directory
# output: rim.nii
build_rim.sh






############################
## BUILDING LAYERS AND COLUMNS
################################
# todo: clean this up
# SUMA
# https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/
# https://layerfmri.com/2020/04/24/equivol/

LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# N3
LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 3
mv equi_distance_layers.nii equi_distance_layers_n3.nii
mv equi_volume_layers.nii equi_volume_layers_n3.nii

# N10
LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 10
mv equi_distance_layers.nii equi_distance_layers_n10.nii
mv equi_volume_layers.nii equi_volume_layers_n10.nii


########################################################
#mkdir LN2_LAYERS_equidist
#mkdir LN2_LAYERS_equivol
#
#cp rim.nii LN2_LAYERS_equidist/
#cp rim.nii LN2_LAYERS_equivol/
#
#cd LN2_LAYERS_equidist
#LN2_LAYERS -rim rim.nii
#
#cd ../LN2_LAYERS_equivol
#LN2_LAYERS -rim rim.nii -equivol
#



#freeview $ANAT *.nii
#freeview $EPI_bias warped_*.nii

##############################
## COLUMNS
#############################
# https://github.com/layerfMRI/LAYNII/issues/13
# can use equidist/equivol
# https://thingsonthings.org/ln2_columns/

# TODO: COLUMNS clean this up, generate colums needs rim_midGM
# LN2_LAYERS might do all nto sure
# use debug to get _columns.nii file
# this also produces the rim_midGM file

# use -incl_borders option to include borders!

LN2_LAYERS -rim rim.nii -equivol -iter_smooth 50 -debug
generate_columns.sh -t "equivol" -n 1000
generate_columns.sh -t "equivol" -n 1000 -b


generate_columns.sh -t "equidist" -n 1000

generate_columns.sh -t "equivol" -n 10000
generate_columns.sh -t "equidist" -n 10000







############################
# BUILD PARCELLATIONS
################################
# BUILD atlas hcpmmp usign multiAtlasTT
# https://github.com/faskowit/multiAtlasTT
# TODO: THE REQUIRES PYTHON. MIGHT NEED TO REWRITE.

conda activate openneuro
warped_MP2RAGE_run_maTT2.sh

# build thalamic segmentation
segmentThalamicNuclei.sh  $subjid

# build brainstem segmentation
segmentBS.sh $subjid

# uild hippocampal segmentation
segmentHA_T1.sh $subjid


