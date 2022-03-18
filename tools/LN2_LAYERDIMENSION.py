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

    img_layers        = nib.load(path_layers)
    data_layers       = img_layers.get_fdata().astype(int)


    unq_cols    = np.unique(data_columns)[1:]
    unq_layers  = np.unique(data_layers)[1:]


    out_shape = data_input.shape


    out_mean    = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2], len(unq_layers)))
    out_sd     = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2], len(unq_layers)))
    out_se      = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2], len(unq_layers)))



    out_mean_3d    = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2]))
    out_sd_3d      = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2]))
    out_se_3d       = np.zeros(shape=(out_shape[0], out_shape[1], out_shape[2]))




    unq_layers_flip = np.flip(unq_layers)


    dimx, dimy, dimz = data_input.shape


    sums = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))
    means = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))
    counts = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))

    #sqr_dev = np.zeros(shape=(data_input.shape))

    stdev = np.zeros(shape=(unq_cols[-1]+1, unq_layers[-1]+1))


    start = time.time()
    print("sum coutns")



    for x in range(dimx): 
        #print(x/dimx*100)
        for y in range(dimy): 
            for z in range(dimz): 
                vox_data    = data_input[x,y,z]
                vox_lay     = data_layers[x,y,z]
                vox_col     = data_columns[x,y,z]
                if (vox_lay != 0) and (vox_col != 0 ): 
                    sums[vox_col, vox_lay] += vox_data
                    counts[vox_col, vox_lay] += 1

    means = sums/counts


    end = time.time()
    print((end - start)/60)




    start = time.time()
    print("summed squared deviation")

    for x in range(dimx): 
        #print(x/dimx*100)
        for y in range(dimy): 
            for z in range(dimz): 
                vox_data    = data_input[x,y,z]
                vox_lay     = data_layers[x,y,z]
                vox_col     = data_columns[x,y,z]

                if (vox_lay != 0) and (vox_col != 0 ): 
                    dev_squared = (means[vox_col, vox_lay] - vox_data)**2
                    #sqr_dev[x,y,z]= dev_squared

                    stdev[vox_col, vox_lay] += dev_squared



    end = time.time()
    print((end - start)/60)


    # start = time.time()
    # print(start)

    # for x in range(dimx): 
    #     for y in range(dimy): 
    #         for z in range(dimz): 
    #             vox_data    = data_input[x,y,z]
    #             vox_lay     = data_layers[x,y,z]
    #             vox_col     = data_columns[x,y,z]

    #             if (vox_lay != 0) and (vox_col != 0 ):  
    #                 stdev[vox_col, vox_lay] += sqr_dev[x,y,z]

    # end = time.time()
    # print((end - start)/60)



    sd = np.sqrt(stdev/(counts - 1 ))

    se = sd/np.sqrt(counts)

    start = time.time()
    print(start)


    print("fill files ")

    # put back in file 
    for x in range(dimx): 
        #print(x/dimx*100)
        for y in range(dimy): 
            for z in range(dimz): 
                vox_data    = data_input[x,y,z]
                vox_lay     = data_layers[x,y,z]
                vox_col     = data_columns[x,y,z]

                if (vox_lay != 0) and (vox_col != 0 ):  

                    layer_out_ind = 0 
                    for unq_layers_flip_ind in unq_layers_flip:

                        out_sd[x,y,z, layer_out_ind]   = sd[vox_col, unq_layers_flip_ind]
                        out_se[x,y,z, layer_out_ind]   = se[vox_col, unq_layers_flip_ind] 
                        out_mean[x,y,z, layer_out_ind] = means[vox_col, unq_layers_flip_ind] 

                        layer_out_ind += 1 


                    out_sd_3d[x,y,z]   = sd[vox_col, vox_lay]
                    out_se_3d[x,y,z]   = se[vox_col, vox_lay] 
                    out_mean_3d[x,y,z] = means[vox_col, vox_lay] 



    end = time.time()
    print((end - start)/60)






    end = time.time()
    print(end - start)

    print('saving files ')

    base_path   = path_input.rstrip(".nii.gz")

    img_mean    = nib.Nifti1Image(out_mean, img_input.affine, img_input.header)
    img_std     = nib.Nifti1Image(out_sd,   img_input.affine, img_input.header)
    img_se      = nib.Nifti1Image(out_se,   img_input.affine, img_input.header)

    nib.save(img_mean,  base_path+".mean.nii.gz")
    nib.save(img_std,   base_path+".std.nii.gz")
    nib.save(img_se,    base_path+".se.nii.gz")



    img_mean_3d    = nib.Nifti1Image(out_mean_3d, img_input.affine, img_input.header)
    img_std_3d     = nib.Nifti1Image(out_sd_3d,   img_input.affine, img_input.header)
    img_se_3d      = nib.Nifti1Image(out_se_3d,   img_input.affine, img_input.header)

    nib.save(img_mean_3d,  base_path+"_3d.mean.nii.gz")
    nib.save(img_std_3d,   base_path+"_3d.std.nii.gz")
    nib.save(img_se_3d,    base_path+"_3d.se.nii.gz")

    print("DONE")

    end = time.time()
    print(end - start)





"""
LN2_LAYERDIMENSION.py \
--input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_2170.R_p10p_pca10_ALL/mean/inv_pe1.fwhm3.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 


LN2_LAYERDIMENSION.py \
--input "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/null_1000/inv_pe1.fwhm7.nii.gz" \
--columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \
--layers "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii" 


"""

