#!/bin/bash
set -e 

#parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
#cd "$parent_path"

# set required paths!
source /home/kleinrl/projects/laminar_fmri/paths_wb_ANAT2
#source_wholebrain2.0


# RUNNING BIAS CORRECTION ON EPI output EPI_bias
# REQUIRES:  EPI (original), spm_path, tools_dir added to PATH
#echo "Running spm_bias_field_correction on ${EPI}"
#spm_bias_field_correct -i ${EPI};


if [ ! -f $ANAT_bias ]; then 
  # RUNNING BIAS CORECTION ON ANAT output is ANAT_bias
  echo "Running spm_bias_field_correction on ${ANAT}"
  spm_bias_field_correct -i ${ANAT};
  else
  echo "not running spm_bais_corr"

fi 





#echo "Running N4BiasFieldCorrection on ${EPI}"
#N4BiasFieldCorrection -d 4 -i $EPI  -o $EPI_bias

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
#run_ANTs -e ${EPI_mean_all_bias} -a ${ANAT_bias}


#freeview ${EPI_bias} ${ANAT_warped}
if [ ! -d $SUBJECTS_DIR  ]; then 
  mkdir -p $SUBJECTS_DIR
  #cp $tools_dir/expert.opts $expert
  cp $tools_dir/FreeSurferColorLUT.txt $LUT_fs
  cp $tools_dir/HCPMMP1_LUT_ordered_RS.txt $SUBJECTS_DIR
  cp $tools_dir/HCPMMP1_LUT_original_RS.txt $SUBJECTS_DIR
  else
  echo "not copyign extra files to SUBEJCTS_DIR"
fi



if [ ! -d "$SUBJECTS_DIR/$subjid" ]; then 
  echo "doesn't exist : $SUBJECTS_DIR/$subjid"
  echo "running recon-all"
  # ANAT_2
  recon-all -all  \
  -i $ANAT_bias \
  -subjid $subjid \
  -parallel -openmp 40 



  # recon-all -all -hires \
  # -i $ANAT_bias \
  # -subjid $subjid \
  # -parallel -openmp 40 
  else
  echo "doesn't exist $SUBJECTS_DIR/$subjid"

  echo "not running recon-all"
fi 



# recon-all -autorecon1 -hires \
#   -i $ANAT_bias \
#   -subjid $subjid \
#   -parallel -openmp 40 \
#   -expert $expert
# MANUAL EDITS - BRAINMASK

# 1) Use SPM's C1,C2 segmentations to brainextract.
# 2) Use Freesurfers gcuts to remove any dura/extra
# 3) manual edits using freeview recon edit mode
# reference -- 01_registration_vaso.sh

# 1) combine c1uncorr.nii and c2uncorr.nii
#3dcalc -a "$ANAT_bias_dir/c1uncorr.nii" \
#-b "$ANAT_bias_dir/c2uncorr.nii" \
#-expr '(a+b)' \
#-prefix "$ANAT_bias_dir/c12uncorr.nii"

# mri_mask [options] <in vol> <mask vol> <out vol>
#mri_mask "$recon_dir/mri/brainmask.mgz" \
#"$ANAT_bias_dir/c12uncorr.nii" \
#"$recon_dir/mri/brainmask.manualedit.nii"

# 2) use mri_gcut to try to get rid of dura
#mri_gcut -110 "$recon_dir/mri/brainmask.manualedit.nii" \
#"$recon_dir/mri/brainmask.manualedit2.nii"

#3 manualedits
# freeview -> recon edit -> shift left click to erase voxels outside brain (Dura,etc.)-> save as brainmask.manualedit#.mgz

#mv "$recon_dir/mri/brainmask.mgz" "$recon_dir/mri/brainmask.backup.mgz"
#cp brainmask.manualedit2.mgz brainmask.mgz



# if [ ! -f $SUBJECTS_DIR/$ANAT_base/mri/brainmask.orig.mgz  ]; then 
# cp $SUBJECTS_DIR/$ANAT_base/mri/brainmask.mgz $SUBJECTS_DIR/$ANAT_base/mri/brainmask.orig.mgz 
# fi 

# if [ ! -f $SUBJECTS_DIR/$ANAT_base/mri/brain.orig.mgz ]; then 
# cp $SUBJECTS_DIR/$ANAT_base/mri/brain.mgz $SUBJECTS_DIR/$ANAT_base/mri/brain.orig.mgz 
# fi 

# if [ ! -f $SUBJECTS_DIR/$ANAT_base/mri/wm.orig.mgz ]; then 
# cp $SUBJECTS_DIR/$ANAT_base/mri/wm.mgz $SUBJECTS_DIR/$ANAT_base/mri/wm.orig.mgz 
# fi 

# if [ ! -f $SUBJECTS_DIR/$ANAT_base/mri/brainmask.mgz  ]; then 
# cp $project_dir/manualedits/brainmask.mgz  $SUBJECTS_DIR/$ANAT_base/mri/brainmask.mgz 
# fi 

# if [ ! -f $SUBJECTS_DIR/$ANAT_base/mri/brain.mgz ]; then 
# cp $project_dir/manualedits/brainmask.mgz  $SUBJECTS_DIR/$ANAT_base/mri/brain.mgz 
# fi 

# if [ ! -f $SUBJECTS_DIR/$ANAT_base/mri/wm.mgz ]; then 
# cp $project_dir/manualedits/wm.mgz  $SUBJECTS_DIR/$ANAT_base/mri/wm.mgz 
# fi 






recon-all -autorecon2  \
  -s $subjid \
  -parallel -openmp 10



# recon-all -autorecon2-wm -autorecon-pial\
#   -hires \
#   -s $subjid \
#   -parallel -openmp 40



# recon-all -autorecon3 -hires \
#   -s $subjid \
#   -parallel -openmp 40



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

if [ ! -f $SUBJECTS_DIR/$subjid/surf/rh.thickness ]; then 
  echo "running mris_make_surfaces $subjid rh "
  mris_make_surfaces $subjid rh
fi 

if [ ! -f $SUBJECTS_DIR/$subjid/surf/lh.thickness ]; then 
  echo "running mris_make_surfaces $subjid lh "
  mris_make_surfaces $subjid lh
fi 




# VISUALIZE
# freeview -v mri/T1.mgz \
# -f surf/lh.white:edgecolor=yellow \
# -f surf/lh.pial:edgecolor=red \
# -f surf/rh.white:edgecolor=yellow \
# -f surf/rh.pial:edgecolor=red

# module load fsl virtualgl freeview 
# vglrun freeview -v mri/T1.mgz \
# -f surf/lh.white:edgecolor=yellow \
# -f surf/lh.pial:edgecolor=red \
# -f surf/rh.white:edgecolor=yellow \
# -f surf/rh.pial:edgecolor=red


cd $recon_dir

# SUMA, build meshes, build rim
# input: recon-all directory
# output: rim.nii


# if [ ! -f $layer_dir/rim.nii ]; then 
#   build_rim.sh
# fi 

if [ ! -f $scaled_EPI ]; then 
  resample_4x.sh $EPI

  3dinfo $scaled_EPI
fi 

if [ ! -f $recon_dir/SUMA_2/rim.nii ]; then 

  cp -r $recon_dir/SUMA $recon_dir/SUMA_2

  build_rim_scaled_renzo.sh

fi




# warping to EPI then resampling to scaled_EPI works but then in specific EPI space 




#3dresample -master $EPI -rmode NN -prefix $rim_EPI_FOV -overwrite -input $rim 

#resample

#build_rim_scaled.sh 
# THIS DOESNT WORK

#resample_RIM.sh
#upsample2scaledEPI_NN.sh $rim 

#3dresample -master $scaled_EPI -rmode NN -overwrite -prefix $out_filepath -input $in



############################
## BUILDING LAYERS AND COLUMNS
################################
# todo: clean this up
# SUMA
# https://layerfmri.com/2017/11/26/getting-layers-in-epi-space/
# https://layerfmri.com/2020/04/24/equivol/

cd $layer_dir 

mkdir layers

cd layers
LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# N3
LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 3
mv equi_distance_layers.nii equi_distance_layers_n3.nii
mv equi_volume_layers.nii equi_volume_layers_n3.nii

# # N10
# LN_LOITUMA -equidist rim_layers.sacled.nii -leaky rim_leaky_layers.scaled.nii -FWHM 1 -nr_layers 10
# mv equi_distance_layers.scaled.nii equi_distance_layers_n10.scaled.nii
# mv equi_volume_layers.scaled.nii equi_volume_layers_n10.scaled.nii





LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# N3
LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 3
mv equi_distance_layers.nii equi_distance_layers_n3.nii
mv equi_volume_layers.nii equi_volume_layers_n3.nii

# # N10
# LN_LOITUMA -equidist rim_layers.sacled.nii -leaky rim_leaky_layers.scaled.nii -FWHM 1 -nr_layers 10
# mv equi_distance_layers.scaled.nii equi_distance_layers_n10.scaled.nii
# mv equi_volume_layers.scaled.nii equi_volume_layers_n10.scaled.nii


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

#LN2_LAYERS -rim rim.nii -equivol -iter_smooth 50 -debug
# generate_columns.sh -t "equivol" -n 1000
# generate_columns.sh -t "equivol" -n 1000 -b
# generate_columns.sh -t "equivol" -n 10000


# generate_columns.sh -t "equidist" -n 1000
generate_columns.sh -t "equidist" -n 10000 -b


# 10000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_midGM_equivol.nii \
-centroids rim_centroids10000.nii -nr_columns 10000 \
-incl_borders -output 'columns_ev_10000_borders.nii'

mv columns_ev_10000_borders_columns10000.nii columns_ev_10000_borders.nii

# 100000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_midGM_equivol.nii \
-centroids rim_centroids10000.nii -nr_columns 50000 \
-incl_borders -output 'columns_ev_10000_borders.nii'

mv columns_ev_100000_borders_columns100000.nii columns_ev_100000_borders.nii


## SCALED 
#LN2_LAYERS -rim rim.nii -equivol -iter_smooth 50 -debug
#generate_columns.sh -t "equivol" -n 1000
#generate_columns.sh -t "equivol" -n 1000 -b
#generate_columns.sh -t "equidist" -n 1000

#generate_columns.sh -t "equivol" -n 10000
#generate_columns.sh -t "equidist" -n 10000

# # SCALED 
# # SCALED N10 ##################
# mkdir -p layers_scaled 
# cd layers_scaled 
# LN_GROW_LAYERS -rim ../rim.scaled.nii -N 1000 -vinc 60 -threeD
# LN_LEAKY_LAYERS -rim ../rim.scaled.nii -nr_layers 1000 -iterations 100

# # N10
# LN_LOITUMA -equidist rim_layers.scaled.nii -leaky rim_leaky_layers.scaled.nii -FWHM 1 -nr_layers 10
# mv equi_distance_layers.scaled.nii equi_distance_layers_n10.scaled.nii
# mv equi_volume_layers.scaled.nii equi_volume_layers_n10.scaled.nii

# cd ..
# mkdir -p columns_scaled 
# cd columns_scaled
# LN2_LAYERS -rim ../rim.scaled.nii -equivol -iter_smooth 50 -debug

# mkdir -p borders
# cd borders
# LN2_COLUMNS -rim ../rim.scaled.nii -midgm ../rim_midGM_equivol.nii -nr_columns 1000 -incl_borders
# LN2_COLUMNS -rim ../rim.scaled.nii -midgm ../rim_midGM_equivol.nii -nr_columns 10000 -incl_borders
# cd ..

# mkdir -p no_borders 
# cd no_borders
# LN2_COLUMNS -rim ../rim.scaled.nii -midgm ../rim_midGM_equivol.nii -nr_columns 1000 
# LN2_COLUMNS -rim ../rim.scaled.nii -midgm ../rim_midGM_equivol.nii -nr_columns 10000 
# cd ..







############################
# BUILD PARCELLATIONS
################################
# BUILD atlas hcpmmp usign multiAtlasTT
# https://github.com/faskowit/multiAtlasTT
# TODO: THE REQUIRES PYTHON. MIGHT NEED TO REWRITE.

#conda activate openneuro
# git clone https://github.com/faskowit/multiAtlasTT $tools_dir/multiAtlasTT
warped_MP2RAGE_run_maTT2.sh

# build thalamic segmentation
segmentThalamicNuclei.sh  $subjid
mri_convert "$recon_dir/mri/ThalamicNuclei.v12.T1.mgz" "$recon_dir/mri/ThalamicNuclei.v12.T1.nii" 

# # build brainstem segmentation
# segmentBS.sh $subjid

# # uild hippocampal segmentation
# segmentHA_T1.sh $subjid


