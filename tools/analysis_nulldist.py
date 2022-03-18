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
    data_columns        = img_columns.get_fdata()

    img_layers        = nib.load(path_layers)
    data_layers       = img_layers.get_fdata()


    unq_cols    = np.unique(data_columns)
    unq_layers  = np.unique(data_layers)


    out_shape = data_input.shape


    out_mean    = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2], len(unq_layers)-1))

    out_std     = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2], len(unq_layers)-1))
    out_se      = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2], len(unq_layers)-1))


    unq_layers_flip = np.flip(unq_layers)



    for uc in unq_cols[1:]:
        print(uc)

        bin_cols = (data_columns == uc)

        out_layer = 0 
        for ul in unq_layers_flip[:-1]: 
            print(ul)

            bin_layers = (data_layers == ul)


            bin_both = bin_layers & bin_cols 



            #ind_col = np.where(bin_cols)
            #ind     = np.where((data_columns == uc) &  )

            #ind_data = data_input[ind]

            ind_data = data_input[bin_both]

            mean    = np.mean(ind_data)
            std     = np.std(ind_data)
            # se      = np.std(ind_data, ddof=1) / np.sqrt(np.size(ind_data))
            se      = std/ np.sqrt(np.size(ind_data))

            if mean == np.nan: 
                mean = 0 
            if std == np.nan: 
                std == 0 
            if se == np.nan: 
                se = 0 


            print(mean, std, se)            

            ind_col = np.where(bin_cols)

            out_mean[ind_col, out_layer]  = mean 
            out_std[ind_col, out_layer]   = std 
            out_se[ind_col, out_layer]    = se 


            # out_mean[bin_cols, out_layer]  = mean 
            # out_std[bin_cols, out_layer]   = std 
            # out_se[bin_cols, out_layer]    = se 

            out_layer += 1 



    end = time.time()
    print(end - start)

    print('saving files ')

    base_path   = path_input.rstrip(".nii.gz")

    img_mean    = nib.Nifti1Image(out_mean, img_input.affine, img_input.header)
    img_std     = nib.Nifti1Image(out_std,  img_input.affine, img_input.header)
    img_se      = nib.Nifti1Image(out_se,   img_input.affine, img_input.header)

    nib.save(img_mean,  base_path+".mean.nii.gz")
    nib.save(img_std,   base_path+".std.nii.gz")
    nib.save(img_se,    base_path+".se.nii.gz")

    print("DONE")

    end = time.time()
    print(end - start)



"""
LN2_LAYERDIMENSION.py --input "/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca10/mean/inv_thresh_zstat1.fwhm8.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 


"""

