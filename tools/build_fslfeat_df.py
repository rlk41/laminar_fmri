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

import csv

if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--fslfeat_dir', type=str)
    #parser.add_argument('--columns', type=str)
    parser.add_argument('--prefix', type=str)
    parser.add_argument('--output', type=str)

    args = parser.parse_args()


    path_input        = args.fslfeat_dir
    #path_columns    = args.columns
    prefix          = args.prefix 
    output          = args.output

    '''
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii"
    path_layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/warped_rim_equidist_n3_layers_equidist.nii"
    path_epi="/data/kleinrl/Wholebrain2.0/DAY3/run5/VASO_LN.nii"

    path_columns_ds="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii.downscaled2x.nii.gz"
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii.downscaled2x.nii.gz"
    path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/L2D.pca_002.nii"

    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_50000_borders.nii"


    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_1000_borders.downscaled2x_NN.nii.gz"
    
    path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/1001.L_V1/VASO_LN.4dmean.2D.pca_000.feat/smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN.fffb-ratioSub.nii.gz"


    path_input='/data/kleinrl/Wholebrain2.0/fsl_feats'
    prefix='smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN.equalcount'
    '''

    #prefix="smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN"
    csvs = glob(path_input+'/*/*.feat/{}.csv'.format(prefix))

    if csvs == []:
        print("no csvs")
         
    else: 
        df = [] 

        for c in csvs: 
            print(c)
            
            cs      = c.split('/')
            seed    = cs[5]
            pca     = cs[6].split('.')[3]
            vol     = cs[-1]


            count = 0 
            with open(c) as csvfile:
                spamreader = csv.reader(csvfile, delimiter=',')
                next(spamreader, None)
                for row in spamreader:
                    out = [seed, pca, int(row[1])]
                    for r in row[2:]:
                        out.append(float(r))
                    out.append(vol)
                    df.append(out)
                                
                    #print(count, out)
                count += 1 
                
        header =    ['seed','seed_pca','target']+\
                    [ 'value_{}'.format(i) for i in range(len(row[2:]))]+\
                    ['vol']

        df = pd.DataFrame(df, columns=header)
        

        #output = '/'.join(path_input.split('/')[0:-1]+['fsl_feats_DF-{}'.format(prefix)])
        outpath = path_input+'/'+'fsl_feats_DF-{}'.format(output)
        df.to_csv(outpath+'.csv')
        df.to_pickle(outpath+'.pkl')

# inv_mean='/data/kleinrl/Wholebrain2.0/fsl_feats/1090.L_10pp/VASO_LN.4dmean.2D.pca_000.feat/inv_mean_func.nii'
# freeview $parc_hcp  $inv_mean *000.feat/smoothed_inv_thresh_zstat1.L2D-columns_ev_1000_borders.downscaled2x_NN.nii.gz