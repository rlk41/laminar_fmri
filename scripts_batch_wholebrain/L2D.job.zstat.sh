#!/bin/bash 

set -e 

    # dir="/data/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/mean"
    # smoothing=1
    # sbatch --mem=50g --cpus-per-task=5 \
    #     --job-name=L2D \
    #     --output=$dir/logs/L2D_fwhm$smoothing.log \
    #     --time 3-0 \
    #     L2D.job.sh $dir $smoothing



# s=( 1 2 3 5 7 8 10)
# dir="/data/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF_V2/mean"
# dir=$(pwd) && echo $dir
# for smoothing in ${s[@]};do 
#   echo $dir $smoothing
#   sbatch --mem=20g --cpus-per-task=5 \
#       --job-name=L2D \
#       --output=$dir/logs/L2D_fwhm$smoothing.log \
#       --time 3-0 \
#       L2D.job.sh $dir $smoothing
# done 

#PuA STS 7PL FEF 


d=$1
smoothing=$2


source /home/kleinrl/projects/laminar_fmri/paths_wholebrain2.0

cd $d

# columns=$columns_50k
# columns_down2xNN=$columns_50k_down2xNN

export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1



columns=$columns_30k
columns_down2xNN=$columns_30k_down2xNN

3dinfo $columns 
3dinfo $columns_down2xNN

base_columns=$(basename $(basename $columns .nii) .nii.gz)


layer_dir="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/"
layers="${layer_dir}/grow_leaky_loituma/equi_volume_layers_n10.nii"



echo "dir:     $d  \n"
echo "pwd:      $(pwd) \n"


echo "checking if thresh_zstat1.nii.gz exists"
if [ ! -f thresh_zstat1.nii.gz ]; then 
    echo "EXITING thresh_zstat1.nii.gz does nto exist " 
    exit
else 
    echo "    exists"
fi 

# TODO change warp_ANTS output to nii.gz 


echo "checking if need to resmaple thresh_zstat.nii"
if [ ! -f inv_thresh_zstat1.nii ]; then 
    echo "    resampling" 
    warp_ANTS_resampleCu_inverse.sh thresh_zstat1.nii.gz $layers
else 
    echo "     exists - dont need to resample "
fi 

echo "checking if need to resmaple inv_mean_func.nii"
if [ ! -f inv_mean_func.nii ]; then 
    echo "    resampling" 
    warp_ANTS_resampleCu_inverse.sh mean_func.nii.gz $layers
else 
    echo "     exists - dont need to resample "
fi 



echo "checking if need to smooth"
if [ ! -f inv_thresh_zstat1.fwhm$smoothing.nii.gz ]; then 
    echo "    SMOOTHING"

    LN_LAYER_SMOOTH -layer_file $layers \
    -input inv_thresh_zstat1.nii -FWHM $smoothing \
    -mask \
    -output inv_thresh_zstat1.fwhm$smoothing.nii.gz
    # -NoKissing \
else 
    echo "    no need to smooth"
fi 



echo "checking if need to L2D"
if [ ! -f inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.nii.gz ]; then 
    echo "    running L2D"

    LN2_LAYERDIMENSION -values inv_thresh_zstat1.fwhm$smoothing.nii.gz \
    -columns $columns \
    -layers $layers \
    -output inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.nii.gz
else 
    echo "    no need to L2D"
fi 


echo "checking if need to downsample"
if [ ! -f inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.nii.gz ]; then 
    echo "    downsample"
    downsample_2x_NN.sh inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.nii.gz
else
    echo "    no need to downsample "
fi 


# 3dTcorr1D -pearson \
# -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.fb_corr.nii.gz  \
# inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
# /home/kleinrl/fb_profile.txt

# 3dTcorr1D -pearson \
# -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_corr.nii.gz  \
# inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
# /home/kleinrl/ff_profile.txt



# 3dTcorr1D -pearson \
# -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.flat_corr.nii.gz  \
# inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
# /home/kleinrl/flat_profile.txt

# 3dTcorr1D -pearson \
# -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.down_corr.nii.gz  \
# inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
# /home/kleinrl/down_profile.txt

# 3dTcorr1D -pearson \
# -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.up_corr.nii.gz  \
# inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
# /home/kleinrl/up_profile.txt

# 3dcalc -a inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_corr.nii.gz  \
# -b inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.fb_corr.nii.gz  \
# -expr 'a-b' -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ratio.nii.gz 



# DETREND AND NORM 
3dTnorm -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.norm.nii.gz \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz 




3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.fb_corr.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/fb_profile.txt

3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_corr.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/ff_profile.txt

3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.flat_corr.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/flat_profile.txt

3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.down_corr.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/down_profile.txt

3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.up_corr.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/up_profile.txt






3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_profile_MGN-A1_L3.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/ff_profile_MGN-A1_L3.txt

3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_profile_MGN-A1_L5.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/ff_profile_MGN-A1_L5.txt


3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_profile_MGN-STV.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/ff_profile_MGN-STV.txt


3dTcorr1D -spearman \
-prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.fb_profile_MGN-A1_L2_L5.nii.gz  \
inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.nii.gz \
/home/kleinrl/projects/laminar_fmri/template_profiles/fb_profile_MGN-A1_L2_L5.txt









3dcalc -a inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_corr.nii.gz  \
-b inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.fb_corr.nii.gz  \
-expr 'a-b' -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ratio.nii.gz 




# plot_mosaic.py --input inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.fb_corr.nii.gz 

# plot_mosaic.py --input inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.ff_corr.nii.gz  

# plot_mosaic.py --input inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.flat_corr.nii.gz  

# plot_mosaic.py --input inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.down_corr.nii.gz 

# plot_mosaic.py --input inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.up_corr.nii.gz  


plot_mosaic.py --input "inv_thresh_zstat1.fwhm$smoothing.L2D.$base_columns.downscaled2x_NN.ratio.nii.gz" --bg "inv_mean_func.nii"

plot_mosaic.py --input "inv_thresh_zstat1.fwhm$smoothing.nii.gz" --bg "inv_mean_func.nii"




# 3dcalc \
# -a inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ff_corr.nii.gz  \
# -b inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.fb_corr.nii.gz  \
# -c inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.flat_corr.nii.gz  \
# -d inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.up_corr.nii.gz  \
# -e inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.down_corr.nii.gz  \
# -expr 'a-b' -prefix inv_thresh_zstat1.fwhm$smoothing.L2D.${base_columns}.downscaled2x_NN.ratio.nii.gz 








# extract_columns_to_df.py \
# --input  smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.nii.gz \
# --columns $columns_downscaled2x_NN2xNN 

#extract_columns_to_df.py \
#--input  smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NNscaled2x_Cu.nii.gz \
#--columns $columns_downscaled2x_NN2xNN 


# normalize 


# corr profile ff


# surf 




# corr profile fb 


# surf



#echo "AVERAGE ACROSS SUBJECTS "

# echo "Running get_fffb_ratio.py"
# get_fffb_ratio.py \
#     --input smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_NN.nii.gz \
#     --columns $columns_downscaled2x_NN2xNN  \
#     --output smoothed_inv_thresh_zstat1.L2D.${base_columns}.down.fffb-ratioSub.nii.gz
# echo "Done NN get_fffb_ratio.py"

# echo "Running get_fffb_ratio.py"
# get_fffb_ratio.py \
#     --input smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_Cu.nii.gz \
#     --columns $columns_down2xNN  \
#     --output smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz
# echo "Done Cu get_fffb_ratio.py"

# extract_columns_to_df.py \
# --input  smoothed_inv_thresh_zstat1.L2D.${base_columns}.down.fffb-ratioSub.nii.gz \
# --columns $columns_down2xNN 

# extract_columns_to_df.py \
# --input  smoothed_inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz \
# --columns $columns_down2xNN 


#################

# echo "Running get_fffb_ratio.py"
# get_fffb_ratio.py \
#     --input inv_thresh_zstat1.L2D.${base_columns}.down.nii.gz \
#     --columns $columns_down2xNN  \
#     --output inv_thresh_zstat1.L2D.${base_columns}.down.fffb-ratioSub.nii.gz
# echo "Done NN get_fffb_ratio.py"

# echo "Running get_fffb_ratio.py"
# get_fffb_ratio.py \
#     --input inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_Cu.nii.gz \
#     --columns $columns_down2xNN  \
#     --output inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz
# echo "Done NN get_fffb_ratio.py"



# extract_columns_to_df.py \
# --input  inv_thresh_zstat1.L2D.${base_columns}.down.fffb-ratioSub.nii.gz \
# --columns $columns_down2xNN 

# extract_columns_to_df.py \
# --input  inv_thresh_zstat1.L2D.${base_columns}.downscaled2x_Cu.fffb-ratioSub.nii.gz \
# --columns $columns_down2xNN 



if [ ! -f inv_thresh_zstat1.fwhm$smoothing.L2D.columns_ev_1000_borders.nii.gz ]; then 
    echo "L2D"

    LN2_LAYERDIMENSION -values inv_thresh_zstat1.fwhm$smoothing.nii.gz \
    -columns $columns_1k \
    -layers $layers \
    -output inv_thresh_zstat1.fwhm$smoothing.L2D.columns_ev_1000_borders.nii.gz
fi 



if [ ! -f inv_thresh_zstat1.fwhm$smoothing.L2D.columns_ev_1000_borders.downscaled2x_NN.nii.gz ]; then 
    echo "downsample"
    downsample_2x_NN.sh inv_thresh_zstat1.fwhm$smoothing.L2D.columns_ev_1000_borders.nii.gz
fi 





L2D_post.job.sh $(pwd)





mkdir -p "$d/hierarchicalClust.fwhm$smoothing"

# get hierarchrical clustering 
3dHierarchicalClust.py \
--input inv_thresh_zstat1.fwhm$smoothing.L2D.columns_ev_1000_borders.downscaled2x_NN.nii.gz  \
--columns $columns_1k_down2xNN \
--output "$d/hierarchicalClust.fwhm$smoothing"






# # gen html 
# html_file="plots.html"
# touch $html_file


# echo "
# <!DOCTYPE html>
# <html>
# <head>
# <title>Page Title</title>
# </head>
# <body>"  | tee -a $html_file 


# for png in *.png; do 
# echo "
# <h1>$png</h1>

# <img src="$png" alt="$png">
# " | tee -a $html_file 
# done 


# echo "
# </body>
# </html>
# "  | tee -a $html_file 





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
