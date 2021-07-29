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

## Equi-distance and Equi-volume layers with Faruk’s implementation as follows:
#../LN2_LAYERS -rim sc_rim.nii -equivol
##for the optional application of medium spatial smoothing, use the following flag.
#-iter_smooth 50
#
#
##Equi-distance layers with Renzo’s implementation as follows:
#../LN_GROW_LAYERS -rim sc_rim.nii
#
##Laplace-like layers with Renzo’s implementation as follows:
#../LN_LEAKY_LAYERS -rim sc_rim.nii

# Equi-volume layers with Renzo’s implementation as follows:


#LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
#LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100
#LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 10
#
#mv rim_layers.nii rim_layers_n10.nii
#mv rim_leaky_layers.nii rim_leaky_layers_n10.nii
#mv leaky_layers.nii leaky_layers_n10.nii
#mv equi_distance_layers.nii equi_distance_layers_n10.nii
#mv equi_volume_layers.nii equi_volume_layers_n10.nii




## ORIGINAL DATA
#LN_GROW_LAYERS -rim rim.nii -N 3 -vinc 10 -threeD -thin
#LN_LEAKY_LAYERS -rim rim.nii -nr_layers 3 -iterations 100
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



freeview $ANAT *.nii

#freeview $EPI_bias warped_*.nii




# LN2_LAYERS -rim rim.nii -centroid ../ -equivol -iter_smooth 50 -debug


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

LN2_LAYERS -rim rim.nii -equivol -iter_smooth 50 -debug
generate_columns.sh -t "equivol" -n 1000
generate_columns.sh -t "equidist" -n 1000







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

#
## COPYING THE ATLASES, ASEG, APARC INTO SESSION SPECIFIC LAYER FOLDER FOR WARPING TO SESSION EPI SPACE
#cp -r $layer_dir $layer4EPI
#cd $layer4EPI
#
#cp $hcp_atlas .
#cp "$recon_dir/mri/ThalamicNuclei.v12.T1.mgz" .
#
## TODO: !!!
## FOR EACH SESSION WE WANT TO TRANSFORM THE ANATOMICAL PARECELATIONS/LAYERS/ATLASES TO EPI SESSION SPACE
## HCP-MMP
#f="$layer4EPI/hcp-mmp-b.nii.gz"
#f_base=$(basename $f .nii.gz)
#f_out="warped_$f_base.nii"
#antsApplyTransforms -d 3 -i $f -o $f_out -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor
#3dcalc -a $f_out -datum short -expr 'a' -prefix $f_out -overwrite
#3dresample -master $EPI_scaled -rmode NN -overwrite -prefix $warp_hcp_scaled  -input $warp_hcp
#
## LAYERS 3
#f="$layer4EPI/leaky_layers_n3.nii"
#f_base=$(basename $f .nii)
#f_out="warped_$f_base.nii"
#antsApplyTransforms -d 3 -i $f -o $f_out -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor
#3dcalc -a $f_out -datum short -expr 'a' -prefix $f_out -overwrite
#3dresample -master $EPI_bias -rmode NN -overwrite -prefix $warp_leakylayers3  -input $warp_leakylayers3
#
#f="$layer4EPI/leaky_layers_n10.nii"
#f_base=$(basename $f .nii)
#f_out="warped_$f_base.nii"
#antsApplyTransforms -d 3 -i $f -o $f_out -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor
#3dcalc -a $f_out -datum short -expr 'a' -prefix $f_out -overwrite
#3dresample -master $EPI_bias -rmode NN -overwrite -prefix $warp_leakylayers10  -input $warp_leakylayers10
#3dresample -master $EPI_scaled -rmode NN -overwrite -prefix $warp_leakylayers10_scaled  -input $warp_leakylayers10
#
#
#
## RIM
#f="$layer4EPI/rim.nii"
#f_base=$(basename $f .nii)
#f_out="$layer4EPI/warped_$f_base.nii"
#antsApplyTransforms -d 3 -i $f -o $f_out -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor
#3dcalc -a $f_out -datum short -expr 'a' -prefix $f_out -overwrite
#3dresample -master $EPI_bias -rmode NN -overwrite -prefix $f_out  -input $f_out
#
## columns_ev_1000
#antsApplyTransforms -d 3 -i $columns_ev_1000 -o $warp_columns_ev_1000 -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor
#3dcalc -a $warp_columns_ev_1000 -datum short -expr 'a' -prefix $warp_columns_ev_1000 -overwrite
#3dresample -master $EPI_scaled -rmode NN -overwrite -prefix $warp_columns_ev_1000_scaled  -input $warp_columns_ev_1000
#
##todo: the columns are a lot thinner
#
## THALAMIC NUCLEI
#f="$layer4EPI/ThalamicNuclei.v12.T1.mgz"
#f_base=$(basename $f .mgz)
#f_out="warped_$f_base.nii"
#antsApplyTransforms -d 3 -i $f -o $f_out -r $EPI_bias -t $ANTs_reg_1warp -t $ANTs_reg_0GenAffine -n NearestNeighbor
#3dcalc -a $f_out -datum short -expr 'a' -prefix $f_out -overwrite
#
##freeview warped_leaky_layers_n3.nii $EPI_bias $ANAT_warped warped_ThalamicNuclei.v12.T1.nii warped_hcp-mmp-b.nii
## creating EPI_scaled_mean for comparison to scaled_columns, scaled_layers, scaled_hcp
#3dTstat -nzmean -prefix $EPI_scaled_mean $EPI_scaled
#
#
##todo: unpack_parc.sh - extract single ROIs from the parc files then find the intersections create_intersecting_rois.sh
## build ROIs - no layer interseciton for thalamic
##unpack_parc_by_LUT.sh
#unpack_parc.sh -r $warp_parc_thalamic -m $LUT_thalamic -o $rois_thalamic
#
#unpack_parc.sh -r $warp_leakylayers3 -m $LUT_leakylayers3 -o $rois_leakylayers3
#
## unpack_parc.sh hcp
## unpack_parc.sh c1k
#
##todo: build_intersecting_rois.sh - change this to use roi files not parc file
## build intersecting ROIs (layer*ROI)
#build_layerxROIs -f $warp_leakylayers3 -l 3 -r $warp_columns -m $LUT_columns -j 60 -o $rois_c1kl3 -c $cmds_buildROIs_c1kl3
#
#build_layerxROIs -f $warp_leakylayers3 -l 3 -r $warp_hcp -m $LUT_hcp -j 60 -o $rois_hcpl3 -c $cmds_buildROIs_hcpl3
#





#python $tools_dir/build_dataframe.py --path $extracted_ts --type 'mean' --savedir $layer4EPI/dataframe_hcp-l3.mean
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois R_Thalamus R_V1 R_MT --quick &
#
#
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_V1 L_V2 --quick  &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick --show &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick --plot True &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois R_Thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_MT L_V1 --quick &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois R_Thalamus L_MT L_V1 --quick &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_4 L_3b L_3a L_1 L_2 --quick &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_4 L_3b L_1 --quick &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_33pr	L_p24pr L_a24pr L_p24 L_a24 L_p32pr L_a32pr L_d32 L_p32 L_s32 L_8BM L_9m L_10v L_10r L_25 --quick &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF --quick &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_Thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 --quick &
#
#
#
#python $tools_dir/generate_fc_from_df.py --path /mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/bandettini_data/ts_numpy_extract_n10_dataframe \
#--rois L_Thalamus L_A1 L_MBelt L_PBelt L_LBelt L_A4 L_A5 L_STSda L_STSdp L_STSva L_STSvp --quick &
#
#
#
## clustering - hierarchrical aglomerative clustering / dendrogram
#python $tools_dir/build_graph2.py --path $layer4EPI/dataframe.hcpl3_thalamic.preprocd \
#--rois L_Thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6
#
## directional graphs
#
#
#
##vol to surf
#























###################################################
###################################################
###################################################
###################################################

#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.none \
#--rois L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois L_MT L_V1 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois R_thalamus L_MT L_V1 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois L_4 L_3b L_3a L_1 L_2 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois L_4 L_3b L_1 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois L_33pr	L_p24pr L_a24pr L_p24 L_a24 L_p32pr L_a32pr L_d32 L_p32 L_s32 L_8BM L_9m L_10v L_10r L_25 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.mean \
#--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &
#
#
#
## cosine
#python $tools_dir/build_dataframe.py --path $extracted_ts --type 'cosine' --savedir $layer4EPI/hcp_l3_dataframe.cosine
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois L_MT L_V1 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois R_thalamus L_MT L_V1 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois L_4 L_3b L_3a L_1 L_2 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois L_4 L_3b L_1 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois L_33pr	L_p24pr L_a24pr L_p24 L_a24 L_p32pr L_a32pr L_d32 L_p32 L_s32 L_8BM L_9m L_10v L_10r L_25 &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois L_TGd L_TGv L_TE2a L_TE2p L_TE1a L_TE1m L_STSvp L_STSdp L_STSva L_STSda L_STGa L_TF &
#
#python $tools_dir/generate_fc_from_df.py --path $layer4EPI/hcp_l3_dataframe.cosine \
#--rois R_thalamus L_V1 L_V2 L_V3 L_V3A L_V3B L_V3CD L_V4 L_V4t L_V6 &
#


## todo: update this throughout
#mkdir $ROIs_columns
#build_layerxROIs -f $warp_leakylayers3 -l 3 -r $warp_columns -m $LUT_columns -j 60 -o $ROIs_columns
#extract_layerxROI_ts -r $ROIs_columns -e $EPI -j 60 -o $ROIs_columns_ts
#python $tools_dir/build_dataframe.py --path $ROIs_columns_ts --type 'mean' --savedir $ROIs_columns_df


#mkdir $AutoTCorr && cd $AutoTCorr
#export OMP_NUM_THREADS=40
#3dAutoTcorrelate -mask $warp_rim -mmap -polort -1 -prefix ${EPI_base_path}.3dTCorr.nii $EPI


#
#build_ROIxROI_plots -i hcp_l3
#build_ROIxROI_plots -i col_equidist_1000_l3
#
#Directed_Connectivity: plot correlation between ROI_l1 vs all other ROI_{l2,l3}
#
#javascript_viewer
#  host_plots_with_selector
#  visualize_brain_graph
#    with_resolutions
#    easy_lausanne
#  timeseries_viewer
#  dimension_reduction_space_viewer
#
#directed_connectivity
#RSA_connectivity
#clustered_conn





# javascript to plot






#
##COLUMNs -- CREATE THE ROI*LAYER ROIS USING 3DCALC
#mkdir $layer4EPI/cmds
#
#col_1000_rim="$layer4EPI/columns_equidist_1000/rim_columns1000.nii"
#col_1000_roi_dir="$layer4EPI/col_equidist_1000_rois"
#
#mkdir $col_1000_roi_dir
#
#while IFS= read -r line; do
#  line=($line)
#  for l in {1..3}; do
#    ID=${line[0]};
#    ROI_name=${line[1]}
#    echo "layer: $l ROI: $roi ID: $ID "
#    echo "3dcalc -a ${warp_leakylayers3} -b $warp_hcp -prefix $out/$ID.$ROI_name.$l.nii -expr 'and(equals(a,$l), equals(b,$ID))' " >> $cmds_build_rois
#  done
#done < $LUT_hcp
#parallel --jobs 50 < $cmds_build_rois
#
## FSLMEANTS TO EXTRACT THE TS USING THE ROI*LAYER ROIs
#
#mkdir $extracted_ts
#rm $cmds_extract_ts
#for roi in $out/*; do
#  o=$extracted_ts/$(basename $roi .nii).txt
#  echo "fslmeants -i $EPI -m $roi -o $o" >> $cmds_extract_ts
#done
#parallel --jobs 60 < $cmds_extract_ts
#
#










## CORRELATIONS IN BASH ?? -- GOING TO BUILD DF IN PTYHON
## AND DO ANAYLSIS IN PYTHON FOR NOW

#out_corrs="$layer4EPI/corrs.txt"
##cmds_corr="$layer4EPI/cmds/cmds_1dCorrelate.txt"
#
#rm $out_corrs $cmds_corr
#
#files=($(ls $extracted_ts))
#n=${#files[@]}
#for x in `seq $n`; do
#  for y in `seq $x $n`; do
#    x_f=${files[$x]}
#    y_f=${files[$y]}
#    #echo "1dCorrelate $extracted_ts/$x_f  $extracted_ts/$y_f >> $out_corrs" >> $cmds_corr
#    1dCorrelate $extracted_ts/$x_f  $extracted_ts/$y_f >> $out_corrs &
#    done
#done
##parallel --jobs 60 < $cmds_corr
#
#combined_ts="$layer4EPI/combined_ts.txt"
#for f in $extracted_ts/*; do cat final.res | paste - $f >temp; cp temp final.res; done; rm temp
#1dCorrelate $extracted_ts/* >> ../corrs.txt
#
#
#
#
#1dplot -noline 1080.L_IFJp.*
#
#1dplot -one -noline 1080.L_IFJp.*








#
##./PREP4MANrim pial_vol.nii WM_vol.nii GM_robbon4_manual_corr.nii
#
##
###source /home/richard/bin/laynii
##
##LAYER_VOL_LEAK rim.nii
##GROW_LAYERS rim.nii
##3dcalc -a leak_vol_lay_rim.nii -b equi_dist_layers.nii -expr 'a-b' -overwrite -prefix difference.nii
##SMinMASK difference.nii rim.nii  30
##3dcalc -a smoothed_difference.nii -b leak_vol_lay_rim.nii -expr 'b-2*a' -overwrite -prefix corrected_leak_1.nii
##SMinMASK corrected_leak_1.nii rim.nii  12
##GLOSSY_LAYERS  smoothed_corrected_leak_1.nii
#
#
#
##get mean value
#3dROIstats -mask equi_dist_layers.nii -1DRformat -quiet -nzmean $1 > layer_t.dat
##get standard deviation
#3dROIstats -mask equi_dist_layers.nii -1DRformat -quiet -sigma $1 >> layer_t.dat
##get number of voxels in each layer
#3dROIstats -mask equi_dist_layers.nii -1DRformat -quiet -nzvoxels $1 >> layer_t.dat
##format file to be in columns, so gnuplot can read it.
#WRD=$(head -n 1 layer_t.dat|wc -w); for((i=2;i layer.dat
#
#
#
#
#
#
##runs with:
## gnuplot
## load "gnuplot_Lyer_me_single_TR.txt"
#
#
#set terminal qt enhanced 40
##set terminal postscript enhanced color solid "Helvetica" 25
##set out "profile.ps"
#
#set title "title"
#set ylabel "activity"
#set xlabel "cortical depth (left is WM, right is CSF)"
#
#plot 	"layer.dat" u 0:($1) w lines title "contrast type 1"  linewidth 3 linecolor rgb "blue"  ,\
#        "layer.dat" u 0:($1):($2)/sqrt($3-1) w yerrorbars title "" pt 1  linewidth 2 linecolor rgb "blue"
#
#
#set term qt
#exit
#
#
#
#
#
