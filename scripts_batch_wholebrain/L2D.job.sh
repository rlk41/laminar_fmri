#!/bin/bash 

set -e 


#EPI=$1

d=$1
#d=$d.feat


source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0

cd $d

#columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_10000_borders.nii"
# columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii"
# columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_50000_borders.nii"

# layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/rim_equidist_n10_layers_equidist.nii"

# columns=$columns_1k
# columns_down2xNN=$columns_1k_down2xNN
# base_columns=$(basename $(basename $columns .nii) .nii.gz)

# layers=$layers_n10

columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_1000_borders.nii"
columns_down2xNN="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_1000_borders.downscaled2x_NN.nii.gz"
base_columns=$(basename $(basename $columns .nii) .nii.gz)

layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/rim_equidist_n10_layers_equidist.nii"

#3dinfo $columns
#3dinfo $columns_down2xNN
#3dinfo $layers



#echo "EPI :    $EPI_3d \n"
# echo "columns: $warp_scaled_columns_ev_10000_borders  \n"
# echo "layers:  $warp_scaled_layers_ed_n10  \n"
echo "dir:     $d  \n"
echo "pwd:      $(pwd) \n"


echo "resampling" 
#resample_4x.sh thresh_zstat1.nii.gz
#3dresample -master $scaled_EPI_master -rmode Cu -overwrite -prefix thresh_zstat1.scaled.nii.gz -input thresh_zstat1.nii.gz
warp_ANTS_resampleCu_inverse.sh thresh_zstat1.nii.gz $layers
warp_ANTS_resampleCu_inverse.sh mean_func.nii.gz $layers

echo "SMOOTHING"
LN_LAYER_SMOOTH -layer_file $layers \
-input inv_thresh_zstat1.nii -FWHM 1.0 \
-mask 

echo "L2D"
# LN2_LAYERDIMENSION -values thresh_zstat1.scaled.nii.gz \
# -columns $columns  \
# -layers $layers \
# -output thresh_zstat1.scaled.L2D.nii.gz



LN2_LAYERDIMENSION -values smoothed_inv_thresh_zstat1.nii \
-columns $columns \
-layers $layers \
-output smoothed_inv_thresh_zstat1.L2D-${base_columns}.nii.gz

LN2_LAYERDIMENSION -values inv_thresh_zstat1.nii \
-columns $columns \
-layers $layers \
-output inv_thresh_zstat1.L2D-${base_columns}.nii.gz


# '''
# echo "normalize L2D"
# 3dNormalizeL2D \
# -input smoothed_inv_thresh_zstat1.L2D-${base_columns}.nii.gz \
# -columns $columns \
# -output smoothed_inv_thresh_zstat1.L2D-${base_columns}.L2D-norm.nii.gz
# '''

# echo "Running get_fffb_ratio.py"
# get_fffb_ratio.py --L2D smoothed_inv_thresh_zstat1.L2D.nii.gz \
#  --columns $columns_30k  --output smoothed_inv_thresh_zstat1.L2D.fffb.nii.gz
# echo "Done get_fffb_ratio.py"



echo "downsample"
# downsample_4x_Cu.sh thresh_zstat1.scaled.L2D.nii.gz
#downsample_4x_Cu.sh inv_thresh_zstat1.L2D.nii.gz
downsample_2x_NN.sh smoothed_inv_thresh_zstat1.L2D-${base_columns}.nii.gz
downsample_2x_Cu.sh smoothed_inv_thresh_zstat1.L2D-${base_columns}.nii.gz
downsample_2x_NN.sh inv_thresh_zstat1.L2D-${base_columns}.nii.gz
downsample_2x_Cu.sh inv_thresh_zstat1.L2D-${base_columns}.nii.gz

#downsample_2x_NN.sh smoothed_inv_thresh_zstat1.L2D.fffb.nii.gz

extract_columns_to_df.py \
--input  smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.nii.gz \
--columns $columns_down2xNN 

extract_columns_to_df.py \
--input  smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.nii.gz \
--columns $columns_down2xNN 





#echo "AVERAGE ACROSS SUBJECTS "

echo "Running get_fffb_ratio.py"
get_fffb_ratio.py \
    --input smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.nii.gz \
    --columns $columns_down2xNN  \
    --output smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.fffb-ratioSub.nii.gz
echo "Done NN get_fffb_ratio.py"

echo "Running get_fffb_ratio.py"
get_fffb_ratio.py \
    --input smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.nii.gz \
    --columns $columns_down2xNN  \
    --output smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz
echo "Done Cu get_fffb_ratio.py"

extract_columns_to_df.py \
--input  smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.fffb-ratioSub.nii.gz \
--columns $columns_down2xNN 

extract_columns_to_df.py \
--input  smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz \
--columns $columns_down2xNN 


#################

echo "Running get_fffb_ratio.py"
get_fffb_ratio.py \
    --input inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.nii.gz \
    --columns $columns_down2xNN  \
    --output inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.fffb-ratioSub.nii.gz
echo "Done NN get_fffb_ratio.py"

echo "Running get_fffb_ratio.py"
get_fffb_ratio.py \
    --input inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.nii.gz \
    --columns $columns_down2xNN  \
    --output inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz
echo "Done NN get_fffb_ratio.py"



extract_columns_to_df.py \
--input  inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.fffb-ratioSub.nii.gz \
--columns $columns_down2xNN 

extract_columns_to_df.py \
--input  inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz \
--columns $columns_down2xNN 







# get hierarchrical clustering 
3dHierarchicalClust.py \
--input smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_NN.nii.gz \
--columns $columns_down2xNN \
--output './hierarchicalClust'





# 3dHierarchicalClust.py \
# --input smoothed_inv_thresh_zstat1.L2D-${base_columns}.downscaled2x_Cu.nii.gz \
# --columns $columns_down2xNN \
# --output './hierarchicalClust'

# get melodic ICA 

