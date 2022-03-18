#!/bin/bash 

# convert the dwscaled_layers.nii file to rim.nii 
layers_to_rim.py 


cd $ds_dir/ANAT

mkdir -p dwscaled 
cd dwscaled 

mv dwscaled_rim.nii rim.nii 

mkdir -p layers 

cd layers 
cp ../rim.nii . 


LN2_LAYERS -rim rim.nii -nr_layers 10 -incl_borders -output rim_equidist_n10 

# LN_GROW_LAYERS -rim rim.nii -N 1000 -vinc 60 -threeD
# LN_LEAKY_LAYERS -rim rim.nii -nr_layers 1000 -iterations 100

# # N10
# LN_LOITUMA -equidist rim_layers.nii -leaky rim_leaky_layers.nii -FWHM 1 -nr_layers 10
# mv equi_distance_layers.nii equi_distance_layers_n10.nii
# mv equi_volume_layers.nii equi_volume_layers_n10.nii


cd ..
mkdir -p columns 
cd columns 

cp ../dwscaled_rim.nii rim.nii 
cp ../layers/rim_equidist_n10_midGM_equidist.nii . 



# 10000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-nr_columns 10000 \
-incl_borders -output 'columns_ev_10000_borders.nii'

mv columns_ev_10000_borders_columns10000.nii columns_ev_10000_borders.nii

# 30000 columns 
LN2_COLUMNS -rim rim.nii -midgm rim_equidist_n10_midGM_equidist.nii \
-centroids columns_ev_10000_borders_centroids10000.nii \
-nr_columns 30000 \
-incl_borders -output 'columns_ev_30000_borders.nii'

mv columns_ev_30000_borders_columns30000.nii columns_ev_30000_borders.nii
