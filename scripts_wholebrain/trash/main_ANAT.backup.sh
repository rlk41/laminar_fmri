#!/bin/bash
set -e 

#parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
#cd "$parent_path"

# set required paths!
source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0
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
  # recon-all -all  \
  # -i $ANAT_bias \
  # -subjid $subjid \
  # -parallel -openmp 40 



  recon-all -all -hires \
  -i $ANAT_bias \
  -subjid $subjid \
  -parallel -openmp 40 
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






# recon-all -autorecon2 -hires \
#   -s $subjid \
#   -parallel -openmp 40


echo "Running autorecon-wm and aurotecon-pial"



# if [ ! -f $manualedit_wm_log ]; then 
#   echo "Creating manualedit_log"
#   touch $manualedit_log
# else
#   echo "manual edit log exists "
# fi 

################
# check if brainmask / wm has changed 
################


# recon-all \
#   -autorecon2-wm \
#   -autorecon-pial \
#   -autorecon3 \
#   -s $subjid \
#   -parallel -openmp 40


# touch $recon_dir/log.autorecon-pial
# echo "running" >> $recon_dir/log.autorecon-pial

# recon-all -autorecon-pial \
#   -s $subjid \
#   -parallel -openmp 40

# echo "done" >> $recon_dir/log.autorecon-pial

# cp -r $SUBJECTS_DIR/ANAT $SUBJECTS_DIR/ANAT_post-pial-ME7-auto

# touch $recon_dir/log.autorecon-WM-AR3
# echo "running" >> $recon_dir/log.autorecon-WM-AR3

# recon-all -autorecon2-wm -autorecon3 \
#   -s $subjid \
#   -parallel -openmp 40

# echo "done" >> $recon_dir/log.autorecon-WM-AR3

# cp -r $SUBJECTS_DIR/ANAT $SUBJECTS_DIR/ANAT_post-wm-ar3-ME5-auto






# recon-all -autorecon3 \
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

# if [ ! -f $SUBJECTS_DIR/$subjid/surf/rh.thickness ]; then 
#   echo "running mris_make_surfaces $subjid rh "
#   mris_make_surfaces $subjid rh
# fi 

# if [ ! -f $SUBJECTS_DIR/$subjid/surf/lh.thickness ]; then 
#   echo "running mris_make_surfaces $subjid lh "
#   mris_make_surfaces $subjid lh
# fi 

# if wm brainmask has changed ... 
# if don't exist 

echo "making surfaces"

cd $recon_dir 

# count=$(ls | grep "SUMA" | wc -l )
# if [ "$count" -gt '0' ]; then
#   mv SUMA SUMA.bak$(ls | grep "SUMA.bak*" | wc -l )
# fi 


# count=$(ls | grep "LAYNII" | wc -l )
# if [ "$count" -gt '0' ]; then
#   echo "moving LAYNII dir"
#   mv LAYNII LAYNII.bak$(ls | grep "LAYNII.bak*" | wc -l )
# fi 

if [ -d "SUMA" ]; then 
  mv SUMA SUMA.bak$(ls | grep "SUMA.bak*" | wc -l )
fi 


if [ -d "LAYNII" ]; then 
  mv LAYNII LAYNII.bak$(ls | grep "LAYNII.bak*" | wc -l )
fi 





mris_make_surfaces $subjid rh
mris_make_surfaces $subjid lh



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

# echo "buidlign rim"
# if [ ! -f $layer_dir/rim.nii ]; then 
#   build_rim.sh
# fi 

#if rerunning 
# rm ./SUMA/subject_name_lh.spec
# rm ./SUMA/subject_name_rh.spec
# rm ./SUMA/subject_name_SurfVol.nii
# rm gzip file 

# rm -rf SUMA 



build_rim.sh

# if [ ! -f $scaled_EPI_mean ]; then 
#   resample_4x.sh $EPI

#   3dinfo $scaled_EPI
# fi 

if [ ! -f $scaled_EPI_master ]; then 
  resample_x.sh $EPI_master 2
fi 


cp -r $recon_dir/SUMA $recon_dir/SUMA_2

cd $recon_dir/SUMA_2

build_rim_scaled_renzo.sh




# if [ ! -f $recon_dir/SUMA_2/rim.nii ]; then 

#   cp -r $recon_dir/SUMA $recon_dir/SUMA_2

#   cd $recon_dir/SUMA_2
  
#   build_rim_scaled_renzo.sh

# fi




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

mkdir -p layers
cd layers

# LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
# LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# # # N3
# # LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 3
# # mv equi_distance_layers.nii equi_distance_layers_n3.nii
# # mv equi_volume_layers.nii equi_volume_layers_n3.nii

# # N10
# LN_LOITUMA -equidist rim_layers.scaled.nii -leaky rim_leaky_layers.scaled.nii -FWHM 1 -nr_layers 10
# mv equi_distance_layers.scaled.nii equi_distance_layers_n10.scaled.nii
# mv equi_volume_layers.scaled.nii equi_volume_layers_n10.scaled.nii

cp ../rim.nii . 

LN2_LAYERS -rim rim.nii -nr_layers 10 -incl_borders -output rim_equidist_n10 

LN2_LAYERS -rim rim.nii -nr_layers 3 -incl_borders -output rim_equidist_n3 


# LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
# LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# # N10
# LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 10
# mv equi_distance_layers.nii equi_distance_layers_n10.nii
# mv equi_volume_layers.nii equi_volume_layers_n10.nii




# LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
# LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# # N3
# LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 3
# mv equi_distance_layers.nii equi_distance_layers_n3.nii
# mv equi_volume_layers.nii equi_volume_layers_n3.nii

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
#generate_columns.sh -t "equidist" -n 10000 -b

cd ..
mkdir -p columns 
cd columns 

cp ../rim.nii . 
cp ../layers/rim_equidist_n10_midGM_equidist.nii . 


#rim_equidist_n10_midGM_equidist.nii


# 10000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-nr_columns 10000 \
-incl_borders -output 'columns_ev_10000_borders.nii'

mv columns_ev_10000_borders_columns10000.nii columns_ev_10000_borders.nii

# 30000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-centroids columns_ev_10000_borders_centroids10000.nii -nr_columns 30000 \
-incl_borders -output 'columns_ev_30000_borders.nii'

mv columns_ev_30000_borders_columns30000.nii columns_ev_30000_borders.nii

# # 10000 columns 
# LN2_COLUMNS -rim rim.nii -midgm rim_midGM_equivol.nii \
# -centroids rim_centroids10000.nii -nr_columns 10000 \
# -incl_borders -output 'columns_ev_10000_borders.nii'

# mv columns_ev_10000_borders_columns10000.nii columns_ev_10000_borders.nii

# # 30000 columns 
# LN2_COLUMNS -rim rim.nii -midgm rim_midGM_equivol.nii \
# -centroids rim_centroids10000.nii -nr_columns 30000 \
# -incl_borders -output 'columns_ev_30000_borders.nii'

# mv columns_ev_30000_borders_columns30000.nii columns_ev_30000_borders.nii


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


cd ${layer_dir}_2

mkdir -p layers
cd layers

cp ../rim.nii . 

LN2_LAYERS -rim rim.nii -nr_layers 10 -incl_borders -output rim_equidist_n10 

LN2_LAYERS -rim rim.nii -nr_layers 3 -incl_borders -output rim_equidist_n3 


cd ..
mkdir -p columns 
cd columns 

cp ../rim.nii . 
cp ../layers/rim_equidist_n10_midGM_equidist.nii . 


# 10000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-nr_columns 10000 \
-incl_borders -output 'columns_ev_10000_borders.nii'

mv columns_ev_10000_borders_columns10000.nii columns_ev_10000_borders.nii

# 30000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-centroids columns_ev_10000_borders_centroids10000.nii -nr_columns 30000 \
-incl_borders -output 'columns_ev_30000_borders.nii'

mv columns_ev_30000_borders_columns30000.nii columns_ev_30000_borders.nii

#50000
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-centroids columns_ev_30000_borders_centroids30000.nii -nr_columns 50000 \
-incl_borders -output 'columns_ev_50000_borders.nii'

mv columns_ev_30000_borders_columns50000.nii columns_ev_50000_borders.nii

# 1000
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-nr_columns 1000 \
-incl_borders -output 'columns_ev_1000_borders.nii'

mv columns_ev_1000_borders_columns1000.nii columns_ev_1000_borders.nii



# sbatch --mem=20g --cpus-per-task=2 \
# --output="$logs/build_columns_50k.log" \
# --time 72:00:00 \
# --job-name="build_cols_50k" \
# "$scripts_batch_dir/build_columns.sh"


cd $recon_dir 



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
segmentBS.sh $subjid

# # uild hippocampal segmentation
segmentHA_T1.sh $subjid



mkdir -p $recon_dir/LAYNII_VASO_LN

cd $recon_dir/LAYNII_VASO_LN

# THALAMIC NUCLEI
#warp_ANTS_resampleNN.sh "$layer4EPI/ThalamicNuclei.v12.T1.mgz" $EPI_bias
warp_ANTS_resampleNN.sh $parc_thalamic $EPI_mean

warp_ANTS_resampleNN.sh $parc_hcp $EPI_mean


cd ${layer_dir}_2/columns 

warp_ANTS_resampleNN.sh $columns_10k $EPI_mean
warp_ANTS_resampleNN.sh $columns_30k $EPI_mean
warp_ANTS_resampleNN.sh $columns_50k $EPI_mean

downsample_2x_NN.sh $columns_30k
downsample_2x_NN.sh $columns_1k
downsample_2x_NN.sh $columns_10k


cd ${layer_dir}_2/layers 

warp_ANTS_resampleNN.sh $layers_n3 $EPI_mean
warp_ANTS_resampleNN.sh $layers_n10 $EPI_mean


# warp_ANTS_resampleNN.sh $parc_hcp $scaled_EPI_master
# warp_ANTS_resampleNN.sh $parc_hcp $scaled_EPI_master
# warp_ANTS_resampleNN.sh $parc_hcp $scaled_EPI_master
# warp_ANTS_resampleNN.sh $parc_hcp $scaled_EPI_master







unpack_parc.sh -r $warp_parc_thalamic \
    -m $LUT_thalamic -o $rois_thalamic 

unpack_parc.sh -r $warp_parc_hcp \
    -m $LUT_hcp -o $rois_hcp 


3dcalc -a $rois_thalamic/8109.lh.LGN.nii -b $rois_thalamic/8209.rh.LGN.nii \
  -expr 'a+b' -prefix $rois_thalamic/both.LGN.nii



unpack_parc.sh -r $warped_layers_n3 \
    -m $LUT_leakylayers3 -o $rois_leakylayers3 

unpack_parc.sh -r $warped_layers_n10 \
    -m $LUT_leakylayers10 -o $rois_leakylayers10 



unpack_parc.sh -r $warp_columns_10k \
    -m $LUT_columns_10k -o $rois_columns_10k

# #todo: build_intersecting_rois.sh - change this to use roi files not parc file

# build_layerxROIs.sh -f $warp_layers_ev_n3 \
#     -l 3 -r $warp_columns -m $LUT_columns \
#     -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3

build_layerxROIs.sh -f $warped_layers_n3 \
    -l 3 -r $warp_parc_hcp -m $LUT_hcp -j 10 \
    -o $rois_hcpl3 -c $cmds_buildROIs_hcpl3











3dMean -prefix 3dTstat.VASO_LN.mean.nii ${EPIs[@]:1:2} -overwrite 
3dMean -prefix 3dTstat.VASO_LN.mean.nii ${EPIs[@]} -overwrite 

# mv /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/DAY1/run4/VASO_LN.nii \
# /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/DAY1/run4/VASO_LN.INCOMPLETE.nii
# mv /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/DAY1/run1/VASO_LN.nii \
# /gpfs/gsfs11/users/kleinrl/Wholebrain2.0/DAY1/run1/VASO_LN.REMOVE_rest.nii


export EPIs=($(find $ds_dir -name "VASO_LN.nii"))

# removed D1R1 D1R4 
3dMean -prefix VASO_LN.4dmean.WITHOUT_D1R1.nii ${EPIs[@]:1:30} 

3dinfo 3dTstat.VASO_LN.mean.nii 


######
######



mkdir -p $fsl_feat_dir
mkdir -p $fsl_feat_ts_dir
mkdir -p $fsl_feat_out

hcp_path=''
rois=("8109.lh.LGN") #both.LGN") # "8209.rh.LGN" 

# "$rois_thalamic/8109.lh.LGN"
roi_paths=( "$rois_thalamic/8109.lh.LGN" \
            "$rois_hcp/1023.L_MT.nii" \
            "$rois_hcp/1001.L_V1.nii" )


EPIs=("/data/kleinrl/Wholebrain2.0/VASO_LN.4dmean.WITHOUT_D1R1.nii")

for roi_path in ${roi_paths[@]}; do 
#for roi in ${rois[@]}; do 
for epi in ${EPIs[@]}; do 

  epi_pre=$(echo $epi | cut -d'/' -f5- )
  epi_pre=$(basename "${epi_pre////_}" .nii)

  #roi="8109.lh.LGN"
  #mask="$rois_thalamic/$roi.nii"
  mask=$roi_path
  roi=$(basename $roi_path .nii)


  timeseries_dir=$fsl_feat_ts_dir/$roi
  timeseries_1D=$timeseries_dir/$epi_pre.1D
  timeseries_2D=$timeseries_dir/$epi_pre.2D
  # timeseries_dir=$fsl_feat_ts_dir/$epi_pre
  # timeseries_1D=$timeseries_dir/$roi.1D
  # timeseries_2D=$timeseries_dir/$roi.2D

  out_dir_1D="$fsl_feat_dir/$roi/$epi_pre.1D"
  #out_dir_1D="$fsl_feat_dir/$epi_pre/$roi.1D"

  echo "epi           $epi"
  echo "epi_pre:      $epi_pre"
  echo "mask:         $mask "
  echo "timeseries_1D $timeseries_1D"
  echo "timeseries_2D $timeseries_2D"
  echo "out_dir_1D    $out_dir_1D" 

  mkdir -p $timeseries_dir

  3dmaskave -q -mask $mask $epi -overwrite >> $timeseries_1D
  #run_fslFeat.sh $epi $timeseries_1D $out_dir_1D

  cd $timeseries_dir

  if [ -f $timeseries_2D ]; then 
    rm $timeseries_2D
  fi 

  3dmaskdump -noijk -mask $mask -o $timeseries_2D -overwrite $epi 
  get_pcas.py --file $timeseries_2D   #--var 0.50

  #ts=($timeseries_dir/$epi_pre.2D.pca*)
  ts=($timeseries_dir/$epi_pre.2D.pca*.1D)
  #ts=($timeseries_dir/$roi.2D.pca*.1D)
  for t in ${ts[@]:0:10}; do 

    #out_dir_2D="$fsl_feat_dir/$epi_pre/$(basename $t .1D)"
    out_dir_2D="$fsl_feat_dir/$roi/$(basename $t .1D)"
    
    echo "epi           $epi"
    echo "epi_pre:      $epi_pre"
    echo "mask:         $mask "
    echo "timeseries_1D $timeseries_1D"
    echo "timeseries_2D $timeseries_2D"
    echo "out_dir_1D    $out_dir_1D" 
    echo "pca:          $t "
    echo "out_dir_2D:   $out_dir_2D"
    
    rm -rf $out_dir_2D 
    #run_fslFeat.sh $epi $t $out_dir_2D 
  
  done 
done 
done 



for d in $fsl_feat_dir/$epi_pre/DAY*/*.feat/thresh_zstat1.nii.gz; do 
  #echo $d
  dir=$(dirname $d)
  echo $dir 
  sbatch --mem=20g --cpus-per-task=5 \
      --job-name=L2D \
      --output=$dir/logs/L2D.log \
      --time 6:00:00 \
      L2D.job.sh $dir
  # # WITH .FEAT APPENDED

done 


rois=("8109.lh.LGN" "8209.rh.LGN" "both.LGN")
for roi in ${rois[@]}; do 


files=$(ls $fsl_feat_dir/*/$roi*pca_002.feat/smoothed_inv_thresh_zstat1.L2D.downscaled2x_NN.fffb-ratioSub.nii.gz)
echo ${files[@]}
3dMean -prefix L2D.$roi.pca_002.ff-fb.nii ${files[@]} -overwrite
done 









3dMean -prefix L2D.pca_002.nii $fsl_feat_dir/*/*pca_001.feat/smo*L2D.downscaled*

export EPIs=($(find $ds_dir -name "VASO_LN.nii"))

# removed D1R1 D1R4 
3dMean -prefix VASO_LN.4dmean.WITHOUT_D1R1.nii ${EPIs[@]:1:30} 





  # roi="8209.rh.LGN"
  # timeseries="$fsl_feat_ts_dir/${roi}.1D"
  # out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
  # 3dmaskave -q -mask "$rois_thalamic/$roi.nii" $EPI_4d >> $timeseries
  # run_fslFeat.sh $EPI_4d $timeseries $out_dir 


  # roi="both.LGN"
  # mask=$rois_thalamic/$roi.nii
  # timeseries="$fsl_feat_ts_dir/${roi}.1D"
  # out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
  # 3dmaskave -q -mask $mask $EPI_4d >> $timeseries

  # run_fslFeat.sh $EPI_4d $timeseries 


  # # /data/kleinrl/Wholebrain2.0/fsl_feats/timeseries/both.LGN.dump

  # 3dmaskdump -noijk -mask $rois_thalamic/8109.lh.LGN.nii -o 8109.lh.LGN.dump $EPI_4d 

  # get_pcas.py --file 8109.lh.LGN.dump
  # #get_pcas.py --var 0.50 --file $fsl_feat_ts_dir/$roi.dump

  # ts=($fsl_feat_ts_dir/8109.lh.LGN.pca*.1D)
  # for t in ${ts[@]:1:15}; do 
  #   echo $EPI_4d 
  #   echo $t 
  #   out_dir=$fsl_feat_out/$(basename $t .1D)
  #   echo $out_dir
  #   rm -rf $out_dir 
  #   run_fslFeat.sh $EPI_4d $t $out_dir 
  # done 


  # 3dmaskdump -noijk -mask $mask -o $roi.dump $EPI_4d 

  # get_pcas.py --file $fsl_feat_ts_dir/$roi.dump
  # #get_pcas.py --var 0.50 --file $fsl_feat_ts_dir/$roi.dump


  # ts=($fsl_feat_ts_dir/both.LGN.pca*.1D)
  # for t in ${ts[@]:1:15}; do 
  #   echo $EPI_4d 
  #   echo $t 
  #   out_dir=$fsl_feat_out/$(basename $t .1D)
  #   echo $out_dir
  #   rm -rf $out_dir 
  #   run_fslFeat.sh $EPI_4d $t $out_dir 
  # done 





# # AVERAGED VASOS

# roi="8109.lh.LGN"
# timeseries="$fsl_feat_ts_dir/${roi}.1D"
# out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"

# 3dmaskave -q -mask "$rois_thalamic/$roi.nii" $EPI_4d >> $timeseries
# run_fslFeat.sh $EPI_4d $timeseries $out_dir 


# roi="8209.rh.LGN"
# timeseries="$fsl_feat_ts_dir/${roi}.1D"
# out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
# 3dmaskave -q -mask "$rois_thalamic/$roi.nii" $EPI_4d >> $timeseries
# run_fslFeat.sh $EPI_4d $timeseries $out_dir 


# roi="both.LGN"
# mask=$rois_thalamic/$roi.nii
# timeseries="$fsl_feat_ts_dir/${roi}.1D"
# out_dir="$fsl_feat_dir/$(basename $timeseries .1D)"
# 3dmaskave -q -mask $mask $EPI_4d >> $timeseries

# run_fslFeat.sh $EPI_4d $timeseries 


# # /data/kleinrl/Wholebrain2.0/fsl_feats/timeseries/both.LGN.dump

# 3dmaskdump -noijk -mask $rois_thalamic/8109.lh.LGN.nii -o 8109.lh.LGN.dump $EPI_4d 

# get_pcas.py --file 8109.lh.LGN.dump
# #get_pcas.py --var 0.50 --file $fsl_feat_ts_dir/$roi.dump

# ts=($fsl_feat_ts_dir/8109.lh.LGN.pca*.1D)
# for t in ${ts[@]:1:15}; do 
#   echo $EPI_4d 
#   echo $t 
#   out_dir=$fsl_feat_out/$(basename $t .1D)
#   echo $out_dir
#   rm -rf $out_dir 
#   run_fslFeat.sh $EPI_4d $t $out_dir 
# done 


# 3dmaskdump -noijk -mask $mask -o $roi.dump $EPI_4d 

# get_pcas.py --file $fsl_feat_ts_dir/$roi.dump
# #get_pcas.py --var 0.50 --file $fsl_feat_ts_dir/$roi.dump


# ts=($fsl_feat_ts_dir/both.LGN.pca*.1D)
# for t in ${ts[@]:1:15}; do 
#   echo $EPI_4d 
#   echo $t 
#   out_dir=$fsl_feat_out/$(basename $t .1D)
#   echo $out_dir
#   rm -rf $out_dir 
#   run_fslFeat.sh $EPI_4d $t $out_dir 
# done 