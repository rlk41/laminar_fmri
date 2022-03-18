#!/bin/bash 

set -e 



d=$1

source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0

cd $d


to_mean=$(ls *ratio.nii.gz)
echo ${to_mean[@]}

3dMean -prefix ratioMean.nii.gz ${to_mean[@]}

plot_mosaic.py \
--input "ratioMean.nii.gz" \
--bg "inv_mean_func.nii"







# for d in $(pwd)/1*; do 

# echo $d 


# cd $d/mean

# to_mean=$(ls *ratio.nii.gz)
# echo ${to_mean[@]}

# 3dMean -prefix ratioMean.nii.gz ${to_mean[@]}

# plot_mosaic.py \
# --input "ratioMean.nii.gz" \
# --bg "inv_mean_func.nii"

# cd ../..


# done 





# plot_mosaic.py \
# --input \
# "inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.ratio.nii.gz" \
# --bg "inv_mean_func.nii"

# plot_mosaic.py --input "inv_thresh_zstat1.fwhm$smoothing.nii.gz" --bg "inv_mean_func.nii"



# @chauffeur_afni                     \
#     -ulay    ratioMean.nii.gz        \
#     -prefix  ratioMean         \
#     -montx 5 -monty 3               \
#     -set_xhairs OFF                 \
#     -label_mode 1 -label_size 4     \
#     -do_clean  

# @chauffeur_afni                       \
#     -ulay  inv_mean_func.nii       \
#     -olay  ratioMean.nii.gz           \
#     -pbar_posonly                     \
#     -cbar "ROI_i256"                  \
#     -func_range 256                   \
#     -opacity 7                        \
#     -prefix   ./PRETTY_PICTURE          \
#     -montx 5 -monty 4                 \
#     -set_xhairs OFF                   \
#     -label_mode 1 -label_size 4       \
#     -cbar_ncolors 6                   \
#     -cbar_topval ""                   \
#     -cbar "1=yellow .6=cyan .3=rbgyr20_10 0=rbgyr20_08 -.3=rbgyr20_05 -.6=rbgyr20_03 -1=none" \
#     -do_clean 

# #     -cbar "1000=yellow 800=cyan 600=rbgyr20_10 400=rbgyr20_08 200=rbgyr20_05 100=rbgyr20_03 0=none" \



# gen html 
html_file="plots.html"
touch $html_file
echo "" > $html_file

echo "
<!DOCTYPE html>
<html>
<head>
<title>Page Title</title>
</head>
<body>"  | tee -a $html_file 


for png in *.png; do 
echo "
<h1>$png</h1>

<img src="$png" alt="$png">
" | tee -a $html_file 
done 


echo "
</body>
</html>
"  | tee -a $html_file 





# get melodic ICA 


# fslmerge -tr inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
# inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz 3


# fslmerge -tr inv_thresh_zstat1.fwhm1.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz \
# inv_thresh_zstat1.fwhm1.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz 3




# echo "resampling" 
# #resample_4x.sh thresh_zstat1.nii.gz
# #3dresample -master $scaled_EPI_master -rmode Cu -overwrite -prefix thresh_zstat1.scaled.nii.gz -input thresh_zstat1.nii.gz
# warp_ANTS_resampleCu_inverse.sh thresh_zstat1.nii.gz $layers
# warp_ANTS_resampleCu_inverse.sh mean_func.nii.gz $layers

# echo "SMOOTHING"
# # LN_LAYER_SMOOTH -layer_file $layers \
# # -input inv_thresh_zstat1.nii -FWHM 10.0 \
# # -mask 
# #-NoKissing \
# #-output 

# LN_LAYER_SMOOTH -layer_file $layers \
# -input inv_thresh_zstat1.nii -FWHM $smoothing \
# -mask \
# -output inv_thresh_zstat1.fwhm$smoothing.nii.gz
# # -NoKissing \



# # LN_LAYER_SMOOTH -layer_file $layers \
# # -input inv_thresh_zstat1.nii -FWHM 7.0 \
# # -mask 

# # LN_LAYER_SMOOTH -layer_file $layers \
# # -input inv_thresh_zstat1.nii -FWHM 5.0 \
# # -mask 

# # LN_LAYER_SMOOTH -layer_file $layers \
# # -input inv_thresh_zstat1.nii -FWHM 4.0 \
# # -mask 


# # LN_LAYER_SMOOTH -layer_file $layers \
# # -input inv_thresh_zstat1.nii -FWHM 3.0 \
# # -mask 

# # LN_LAYER_SMOOTH -layer_file $layers \
# # -input inv_thresh_zstat1.nii -FWHM 2.0 \
# # -mask 







# echo "L2D"
# # LN2_LAYERDIMENSION -values thresh_zstat1.scaled.nii.gz \
# # -columns $columns  \
# # -layers $layers \
# # -output thresh_zstat1.scaled.L2D.nii.gz



# LN2_LAYERDIMENSION -values inv_thresh_zstat1.fwhm$smoothing.nii.gz \
# -columns $columns \
# -layers $layers \
# -output inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.nii.gz



# # LN2_LAYERDIMENSION -values smoothed_inv_thresh_zstat1.nii \
# # -columns $columns \
# # -layers $layers \
# # -output smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz


# # 3dDetrend -polort 1 -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.detrend_1.nii.gz \
# # smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.nii.gz

# # 3dDetrend -polort 1 -normalize -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.detrend_1.norm.nii.gz \
# # smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.nii.gz

# # 3dDetrend -polort 2 -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.detrend_2.nii.gz \
# # smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.nii.gz

# # 3dDetrend -polort 2 -normalize -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.detrend_2.norm.nii.gz \
# # smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.nii.gz



# # 3dDetrend -polort 1 -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.detrend_1.nii.gz smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz
# # 3dDetrend -polort 1 -normalize -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.detrend_1.norm.nii.gz smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz


# # 3dDetrend -polort 2 -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.detrend_2.nii.gz smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz
# # 3dDetrend -polort 2 -normalize -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.detrend_2.norm.nii.gz smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz

# # 3dDetrend -polort 3 -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.detrend_3.nii.gz smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz
# # 3dDetrend -polort 3 -normalize -prefix smoothed_inv_thresh_zstat1.L2D.${base_columns}.detrend_3.norm.nii.gz smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz








# # LN2_LAYERDIMENSION -values inv_thresh_zstat1.nii \
# # -columns $columns \
# # -layers $layers \
# # -output inv_thresh_zstat1.L2D.${base_columns}.nii.gz


# # '''
# # echo "normalize L2D"
# # 3dNormalizeL2D \
# # -input smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz \
# # -columns $columns \
# # -output smoothed_inv_thresh_zstat1.L2D.${base_columns}.L2D.norm.nii.gz
# # '''

# # echo "Running get_fffb_ratio.py"
# # get_fffb_ratio.py --L2D smoothed_inv_thresh_zstat1.L2D.nii.gz \
# #  --columns $columns_30k  --output smoothed_inv_thresh_zstat1.L2D.fffb.nii.gz
# # echo "Done get_fffb_ratio.py"



# echo "downsample"
# # downsample_4x_Cu.sh thresh_zstat1.scaled.L2D.nii.gz
# #downsample_4x_Cu.sh inv_thresh_zstat1.L2D.nii.gz

# #downsample_2x_NN.sh smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz
# downsample_2x_NN.sh inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.nii.gz

# # downsample_2x_Cu.sh smoothed_inv_thresh_zstat1.L2D.${base_columns}.nii.gz
# # downsample_2x_NN.sh inv_thresh_zstat1.L2D.${base_columns}.nii.gz
# # downsample_2x_Cu.sh inv_thresh_zstat1.L2D.${base_columns}.nii.gz

# #downsample_2x_NN.sh smoothed_inv_thresh_zstat1.L2D.fffb.nii.gz
