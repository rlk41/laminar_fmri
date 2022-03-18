#!/bin/bash 

set -e 


EPI=$1

d=$2 

source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0

cd $d

echo "EPI :    $EPI_3d \n"
# echo "columns: $warp_scaled_columns_ev_10000_borders  \n"
# echo "layers:  $warp_scaled_layers_ed_n10  \n"
echo "dir:     $d  \n"
echo "pwd:      $(pwd) \n"


echo "resmapling" 
#resample_4x.sh thresh_zstat1.nii.gz
3dresample -master $scaled_EPI_master -rmode Cu -overwrite -prefix thresh_zstat1.scaled.nii.gz -input thresh_zstat1.nii.gz


columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_10000_borders.nii"
layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/rim_equidist_n10_layers_equidist.nii"

echo "L2D"
LN2_LAYERDIMENSION -values thresh_zstat1.scaled.nii.gz \
-columns $columns  \
-layers $layers \
-output thresh_zstat1.scaled.L2D.nii.gz



echo "downsample"
downsample_4x_Cu.sh thresh_zstat1.scaled.L2D.nii.gz




echo "done"