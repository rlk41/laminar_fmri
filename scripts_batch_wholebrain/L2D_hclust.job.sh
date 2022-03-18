#!/bin/bash 

set -e 


#   sbatch --mem=10g --cpus-per-task=5 \
#       --job-name=L2D \
#       --output=$dir/logs/L2D_fwhm$smoothing.log \
#       --time 3-0 \
#       L2D_hclust.job.sh $dir $smoothing

d=$1
smoothing=$2


source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0

cd $d


columns=$columns_1k
columns_down2xNN=$columns_1k_down2xNN

base_columns=$(basename $(basename $columns .nii) .nii.gz)

layer_dir="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/"
layers="${layer_dir}/grow_leaky_loituma/equi_volume_layers_n10.nii"


echo "dir:     $d  \n"
echo "pwd:      $(pwd) \n"



if [ ! -f inv_thresh_zstat1.nii ]; then 
    echo "resampling" 
    warp_ANTS_resampleCu_inverse.sh thresh_zstat1.nii.gz $layers
fi 

if [ ! -f inv_mean_func.nii ]; then 
    echo "resampling" 
    warp_ANTS_resampleCu_inverse.sh mean_func.nii.gz $layers
fi 




if [ ! -f inv_thresh_zstat1.fwhm$smoothing.nii.gz ]; then 
    echo "SMOOTHING"

    LN_LAYER_SMOOTH -layer_file $layers \
    -input inv_thresh_zstat1.nii -FWHM $smoothing \
    -mask \
    -output inv_thresh_zstat1.fwhm$smoothing.nii.gz
    # -NoKissing \
fi 




if [ ! -f inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.nii.gz ]; then 
    echo "L2D"

    LN2_LAYERDIMENSION -values inv_thresh_zstat1.fwhm$smoothing.nii.gz \
    -columns $columns \
    -layers $layers \
    -output inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.nii.gz
fi 



if [ ! -f inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.nii.gz ]; then 
    echo "downsample"
    downsample_2x_NN.sh inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.nii.gz
fi 




mkdir -p "$d/hierarchicalClust.fwhm$smoothing"

# get hierarchrical clustering 
3dHierarchicalClust.py \
--input $d/inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.nii.gz  \
--columns $columns_down2xNN \
--output $d/hierarchicalClust.fwhm$smoothing


