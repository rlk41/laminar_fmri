#!/usr/bin/env python

import os
from glob import glob
from numpy.lib.function_base import corrcoef
import pandas as pd
import argparse
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity, cosine_distances, paired_cosine_distances
from scipy.special import betainc
import matplotlib.pyplot as plt
import scipy
import pylab
import scipy.cluster.hierarchy as sch
import nibabel as nib 
from multiprocessing import Pool 
from shutil import copyfile
from scipy.spatial.distance import euclidean

from fastdtw import fastdtw


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--input', type=str)
    parser.add_argument('--columns', type=str)
    #parser.add_argument('--output', type=str)
    args = parser.parse_args()


    path_input        = args.input
    path_columns    = args.columns
    #output          = args.output 


    '''
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii"
    path_layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/warped_rim_equidist_n3_layers_equidist.nii"
    path_epi="/data/kleinrl/Wholebrain2.0/DAY3/run5/VASO_LN.nii"

    path_columns_ds="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii.downscaled2x.nii.gz"
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii.downscaled2x.nii.gz"
    path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/L2D.pca_002.nii"

    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_50000_borders.nii"


    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_1000_borders.downscaled2x_NN.nii.gz"
    
    path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/1090.L_10pp/VASO_LN.4dmean.2D.pca_000.feat/smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN.nii.gz"



    '''

    img_input         = nib.load(path_input)
    data_input        = img_input.get_fdata()

    img_columns     = nib.load(path_columns)
    data_columns   = img_columns.get_fdata()

    
    output = path_input.split('/')[-1].rstrip('.nii.gz').rstrip('.nii')+'.csv'

    out = data_columns.copy()

    row = []

    unq_column_ids     = np.unique(data_columns).astype(int)[1:]
    for unq_column_id in unq_column_ids: 
        '''
        unq_column_id = ff_ids[0]
        unq_column_id = fb_ids[0]
        '''

        inds             = np.where(data_columns == unq_column_id) 
        inds_data        = data_input[inds]
        inds_data_mean   = np.mean(inds_data,0)
        
        l = inds_data_mean.tolist()
        row.append([unq_column_id]+l)
    
    header = ['id']+['value_{}'.format(i) for i in range(len(l))]
    df = pd.DataFrame(row, columns=header)
    
    df.to_csv(output)
