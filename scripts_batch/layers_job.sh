#!/bin/bash 
set -e 


cd $layer_dir 

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
