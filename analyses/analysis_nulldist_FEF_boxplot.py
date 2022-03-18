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
import matplotlib.pyplot as plt 
import time
import pandas as pd 

import glob 
import scipy 


def get_plots(k): 



    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF/plots"
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"
    LUT="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/HCPMMP1_LUT_ordered_RS.txt"

    lut = pd.read_csv(LUT, delimiter=' ')

    print('load lut')

    #k = 'L_FEF'

    k_id = int(lut[lut['Lookup'] == k]['#'].values[0])

    print("{} {}".format(k, k_id))


    # keys = {'L_FEF':10,     'L_LIPv':48,    'L_VIP':9,      'L_V4t':156,    'R_V4':186,
    #         'R_V2':184,     'R_V3':185,     'L_V1':1,       'L_MST':2,      'L_MT':23,
    #         'L_TF':135,     'L_TE1a':132,   'L_TE1p':133,   'L_TE2a':134,   'L_TE2p':136,
    #         'L_FST':157 }




    #columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.downscaled2x_NN.nii.gz"
    parc                = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.nii.gz"
    nulls_3d            = glob.glob(base_dir+"/fsl_feat_*NULL*/mean/inv_pe1.fwhm7.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")


    # nulls_3d_data =     []
    # for null in nulls_3d: 
    #     img_null            = nib.load(null)
    #     data_null           = img_null.get_fdata()

    #     nulls_3d_data.append(data_null)



    feat_3d             = base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz"
    nulls_npy           = ""
    feat_npy            = ""
    img_parc            = nib.load(parc)
    img_col             = nib.load(columns)

    data_parc           = img_parc.get_fdata()
    data_columns        = img_col.get_fdata()

    #for k in keys.keys(): 

    # k = 'L_FEF'
    #ind_roi     = np.where(data_parc == keys[k] )
    ind_roi     = np.where(data_parc == k_id )

    unq_roi_col = np.unique(data_columns[ind_roi]) 
    unq_roi_col = [ uc for uc in unq_roi_col if uc != 0 ]

    print("unique columns: {}".format(len(unq_roi_col)))


    for uc in unq_roi_col: 

        # uc = unq_roi_col[0]
        ind_col = np.where(data_columns == uc)
        uc      = int(uc) 


        fig = plt.figure()
        ax = fig.add_axes([0.1, 0.1, 0.8, 0.8]) # main axes

        boxplots = [] 
        null_i = 0 
        for null in nulls_3d: 
            # null = nulls_3d[0]
            img_null  = nib.load(null)
            data_null = img_null.get_fdata()

            y = np.flip(data_null[ind_col][0,:]) 
            x = np.array([ x for x in range(1, y.shape[0]+1 )])
            #plt.plot(x, y, color='blue')
            print("null_i {}".format(null_i))
            null_i += 1 

            boxplots.append(y)

        img_feat  = nib.load(feat_3d)
        data_feat = img_feat.get_fdata()

        y_sample = np.flip(data_feat[ind_col][0,:]) 
        x_sample = np.array([ x for x in range(1, y_sample.shape[0]+1 )])
        plt.plot(x_sample, y_sample, color='red')

        #boxplots.append(y)

        b = np.stack(boxplots)

        # torun = False 
        # if torun == True:
        #     bps = [] 
        #     for bp in range(b.shape[1]):
                
        #         bp_x = b[:,bp]
        #         bp_y = y_sample[bp]

        #         scipy.stats.wilcoxon(bp_x.tolist(), bp_y, alternative='greater')

        #         # y=np.array(bp_y)

        plt.boxplot(b)




        tit = "{}-{}".format(k, uc) 
        plt.title(tit )

        ax.set_xticks([1,10])
        ax.set_xticklabels(['CSF','WM'])


        plt.ylabel('beta weights')

        plt.savefig(plot_dir+"/{}.box2.png".format(tit))
        plt.close()

        print("plot saved -- {} {}".format(k, uc))



if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--k', type=str)

    args = parser.parse_args()

    k = args.k 

    get_plots(k)


'''
rois=(L_FEF L_LIPv L_VIP L_V4t R_V4 R_V2 R_V3 L_V1 L_MST L_MT
    L_TF L_TE1a L_TE1p L_TE2a L_TE2p L_FST)

for r in ${rois[@]}; do 
    echo "python analysis_nullDist_FEF.py --k $r " >> swarm.plots
done 

'''
