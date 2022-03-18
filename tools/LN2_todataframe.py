#!/usr/bin/env python

import os
from numpy.lib.function_base import corrcoef
import argparse
import numpy as np
import matplotlib.pyplot as plt
import pylab
import scipy.cluster.hierarchy as sch
import nibabel as nib 
from nilearn.input_data import NiftiLabelsMasker
import pickle 

import time




if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--input', type=str)

    parser.add_argument('--columns', type=str)
    parser.add_argument('--layers', type=str)

    parser.add_argument('--output', type=str)
    args = parser.parse_args()

    path_input      = args.input

    path_columns    = args.columns
    path_layers     = args.layers

    path_output     = args.output 

    '''
    path_input      = "/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca10/mean/inv_thresh_zstat1.fwhm8.nii.gz"
    path_input      = "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.nii.gz"

    path_columns    = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    path_layers     = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii"

    '''

    print("path_input:   "    + path_input)
    print("path_columns: "  + path_columns)
    print("path_layers:  "   + path_layers)
    print()

    start = time.time()
    print(start)


    img_input           = nib.load(path_input)
    data_input          = img_input.get_fdata()

    img_columns         = nib.load(path_columns)
    data_columns        = img_columns.get_fdata().astype(int)

    img_layers          = nib.load(path_layers)
    data_layers         = img_layers.get_fdata().astype(int)


    unq_cols    = np.unique(data_columns)[1:]
    unq_layers  = np.unique(data_layers)[1:]

    out_shape = data_input.shape

    unq_layers_flip = np.flip(unq_layers)

    dimx, dimy, dimz = data_input.shape

    sums    = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))
    means   = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))
    counts  = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))



    for x in range(dimx): 
        for y in range(dimy): 
            for z in range(dimz): 
                vox_data    = data_input[x,y,z]
                vox_lay     = data_layers[x,y,z]
                vox_col     = data_columns[x,y,z]
                if (vox_lay != 0) and (vox_col != 0 ): 
                    sums[vox_col, vox_lay] += vox_data
                    counts[vox_col, vox_lay] += 1

    means = sums/counts



    base_path   = path_input.rstrip(".nii.gz")
    base_col    = path_columns.rstrip(".nii.gz").split('/')[-1]
    base_layers = path_layers.rstrip(".nii.gz").split('/')[-1]


    np.save("{}.{}.{}.means.npy".format(base_path, base_layers, base_col), means, 
                allow_pickle=True, fix_imports=True)





"""
LN2_todataframe.py \
--input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_2170.R_p10p_pca10_ALL/mean/inv_pe1.fwhm3.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 

LN2_todataframe.py \
--input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_2170.R_p10p_pca10_ALL/mean/inv_pe1.fwhm3.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b.nii.gz" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 




"""

