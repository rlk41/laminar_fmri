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
    parser.add_argument('--output', type=str)
    args = parser.parse_args()


    path_input        = args.input
    path_columns    = args.columns
    output          = args.output 


    '''
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii"
    path_layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/warped_rim_equidist_n3_layers_equidist.nii"
    path_epi="/data/kleinrl/Wholebrain2.0/DAY3/run5/VASO_LN.nii"

    path_columns_ds="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii.downscaled2x.nii.gz"
    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii.downscaled2x.nii.gz"
    path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/L2D.pca_002.nii"

    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_50000_borders.nii"


    path_columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii"
    path_input="/data/kleinrl/Wholebrain2.0/fsl_feats/DAY1_run5_VASO_LN/both.LGN.2D.pca_010.feat/smoothed_inv_thresh_zstat1.L2D.nii.gz"

    '''

    img_input         = nib.load(path_input)
    data_input        = img_input.get_fdata()

    img_columns     = nib.load(path_columns)
    data_columns   = img_columns.get_fdata()

    
    out = data_columns.copy()


    create_profiles=False
    if create_profiles == True:

        path_columns_ds="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_30000_borders.nii.downscaled2x.nii.gz"


        ## GENERATING PROFILES 
        img_columns_ds     = nib.load(path_columns_ds)
        data_columns_ds    = img_columns_ds.get_fdata()

        img_profiles = nib.load('/data/kleinrl/Wholebrain2.0/fsl_feats/L2D.pca_002.nii')
        data_profiles = img_profiles.get_fdata() 

        ff_ids = [26284]#[12805] #, 20583, 28412, 10184, 20522, 14935, 17118, 12199, ]
        ff_ps = [] 
        for id in ff_ids:
            inds = np.where(data_columns_ds == id )
            d = data_profiles[inds[0],inds[1],inds[2], :]
            p = np.mean(d,0)
            p = (p - np.mean(p))/np.std(p)
            ff_ps.append(p)

        ff_ps = np.mean(ff_ps,0)
        plt.plot([x for x in range(len(ff_ps))], ff_ps)
        plt.savefig('ff_profile.png')
        np.savetxt('ff_profile.txt',ff_ps)


        fb_ids = [12805] #[12794, 13458, 19345, 28267, 20519, 28232, 28230]
        fb_ps = [] 
        for id in fb_ids:
            inds = np.where(data_columns_ds == id )
            d = data_profiles[inds[0],inds[1],inds[2], :]
            p = np.mean(d,0)
            p = (p - np.mean(p))/np.std(p)
            fb_ps.append(p)

        fb_ps = np.mean(fb_ps,0)
        plt.plot([x for x in range(len(fb_ps))], ff_ps)
        plt.savefig('fb_profile.png')
        np.savetxt('fb_profile.txt',fb_ps)


    ff_ps = np.array([-0.95088414, -0.59177142,  0.17633744,  1.4424729 ,  1.24481643,
        1.31553988,  0.18318057, -0.27174834, -1.28345969, -1.26448362])
    fb_ps = np.array([-0.44530771,  0.60670543,  1.66233666,  0.66287436, -1.08918178,
       -0.30745872,  0.91616032,  0.65961318, -1.08541645, -1.58032529])

    plot_num = 0 
    unq_column_ids     = np.unique(data_columns).astype(int)[1:]
    for unq_column_id in unq_column_ids: 
        '''
        unq_column_id = ff_ids[0]
        unq_column_id = fb_ids[0]
        '''

        inds             = np.where(data_columns == unq_column_id) 
        inds_data        = data_input[inds]
        inds_data_mean   = np.mean(inds_data,0)
        inds_data_zscore = (inds_data_mean - np.mean(inds_data_mean))/np.std(inds_data_mean)

        #up_ps       = np.linspace(-1,1,num=10) 
        #down_ps     = np.linspace(1,-1,num=10) 
        #no_ps       = [0.1]*10

        ff_corr     = np.corrcoef(ff_ps,    inds_data_zscore)[0,1]
        fb_corr     = np.corrcoef(fb_ps,    inds_data_zscore)[0,1]
        # up_corr     = np.corrcoef(up_ps,    inds_data_zscore)[0,1]
        # down_corr   = np.corrcoef(down_ps,  inds_data_zscore)[0,1]
        # no_corr     = np.corrcoef(no_ps,    inds_data_zscore)[0,1]
        #if str(no_corr) == "nan": 
        #    no_corr = 0 

        # ff_corr, ff_path = fastdtw(ff_ps, inds_data_zscore, dist=euclidean)
        # fb_corr, fb_path = fastdtw(fb_ps, inds_data_zscore, dist=euclidean)

        #ratio = ff_corr/fb_corr
        ratio = ff_corr - fb_corr

        # if ff_corr > np.max([fb_corr, up_corr, down_corr, no_corr]):
        #     ratio = ff_corr
        # elif fb_corr > np.max([ff_corr, up_corr, down_corr, no_corr]):
        #     ratio = fb_corr * -1 
        # else:
        #     ratio = 0 


        out[inds] = ratio


        print("col: {} ff: {:.2f} fb: {:.2f} ratio: {:.2f}"
            .format(unq_column_id, ff_corr, fb_corr, ratio))

        # create_plots = True 
        # while plot_num < 100 and create_plots == True : 
        #     plt.plot([x for x in range(len(ff_ps))], ff_ps, label='ff')
        #     plt.plot([x for x in range(len(fb_ps))], fb_ps, label='fb')
        #     plt.plot([x for x in range(len(up_ps))], up_ps, label='up')
        #     plt.plot([x for x in range(len(down_ps))], down_ps, label='down')
        #     plt.plot([x for x in range(len(no_ps))], no_ps, label='no')
        #     plt.plot([x for x in range(len(inds_data_zscore))], inds_data_zscore, label='col')

        #     plt.title('col_{}: ff: {:.2f} fb: {:.2f} ratio: {:.2f}'
        #         .format(unq_column_id, ff_corr, fb_corr, ratio))
        #     plt.legend()
        #     #plotdir="/data/kleinrl/Wholebrain2.0/fsl_feats/plots/"
        #     plotdir="./plots/"
        #     os.makedirs(plotdir, exist_ok=True)
        #     plt.savefig('{}/{}_plot.png'.format(plotdir, unq_column_id))
        #     plt.close()

        # plot_num += 1 


    out_img = nib.Nifti1Image(out, img_columns.affine, img_columns.header)
    if output == None:
        nib.save(out_img, path_input.rstrip('.nii')+'.ff-fb.nii' )
    else: 
        nib.save(out_img, output )

