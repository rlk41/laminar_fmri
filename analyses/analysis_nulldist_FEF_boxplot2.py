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

from matplotlib.pylab import plot, boxplot, show, savefig, xlim, figure, \
                ylim, legend, setp, axes




def get_plots(k): 



    plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF/plots"
    base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"
    LUT="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/HCPMMP1_LUT_ordered_RS.txt"

    lut = pd.read_csv(LUT, delimiter=' ')

    print('load lut')

    #k = 'L_V4'

    k_id = int(lut[lut['Lookup'] == k]['#'].values[0])

    print("{} {}".format(k, k_id))


    # keys = {'L_FEF':10,     'L_LIPv':48,    'L_VIP':9,      'L_V4t':156,    'R_V4':186,
    #         'R_V2':184,     'R_V3':185,     'L_V1':1,       'L_MST':2,      'L_MT':23,
    #         'L_TF':135,     'L_TE1a':132,   'L_TE1p':133,   'L_TE2a':134,   'L_TE2p':136,
    #         'L_FST':157 }




    #columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
    parc                = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.scaled2x.nii.gz"
    layers              = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/layers/grow_leaky_loituma/equi_volume_layers_n10.nii"
    nulls_3d            = glob.glob(base_dir+"/fsl_feat_*NULL*/mean/inv_pe1.fwhm3.nii.gz") #fwhm7.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")

    # nulls_3d_data =     []
    # for null in nulls_3d: 
    #     img_null            = nib.load(null)
    #     data_null           = img_null.get_fdata()
    #     nulls_3d_data.append(data_null)

    feat_3d             = base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm3.nii.gz" #L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")
    nulls_npy           = ""
    feat_npy            = ""
    img_parc            = nib.load(parc)
    img_col             = nib.load(columns)
    img_lay             = nib.load(layers)

    data_parc           = img_parc.get_fdata()
    data_columns        = img_col.get_fdata()
    data_layers            = img_lay.get_fdata()

    #for k in keys.keys(): 

    # k = 'L_FEF'
    #ind_roi     = np.where(data_parc == keys[k] )
    ind_roi     = np.where(data_parc == k_id )

    unq_roi_col = np.unique(data_columns[ind_roi]) 
    unq_roi_col = [ uc for uc in unq_roi_col if uc != 0 ]

    unq_layers = np.flip(np.unique(data_layers))[:-1]

    print("unique columns: {}".format(len(unq_roi_col)))


    for uc in unq_roi_col: 

        # uc = unq_roi_col[0]
        #ind_col = np.where(data_columns == uc)
        ind_col = data_columns == uc

        uc      = int(uc) 


        fig = plt.figure()
        ax = fig.add_axes([0.1, 0.1, 0.8, 0.8]) # main axes


        boxplots = [] 
        null_i = 0 
        data_null_mean = np.zeros(shape=data_columns.shape)


        null_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]
        # null_layer_data = group_layer_data 
        for null in nulls_3d: 
            # null = nulls_3d[0]
            img_null  = nib.load(null)
            data_null = img_null.get_fdata()


            for lc in unq_layers: 
                ind_lay = data_layers == lc 
                ind_both = np.where( ind_lay & ind_col )

                null_layer_data[int(lc)].append( data_null[ ind_both ] )


        # mean_null_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]
        # for g in range(1, len(null_layer_data)): 
        #     mean_null_layer_data[g] = np.mean(null_layer_data[g], axis=0)
        #     null_layer_data[g]      = np.concatenate(null_layer_data[g]).flatten().tolist()



        img_feat  = nib.load(feat_3d)
        data_feat = img_feat.get_fdata()

        emp_layer_data = [ [] for lc in range(0, int(np.max(unq_layers))+1 ) ]


        for lc in unq_layers: 
            ind_lay = data_layers == lc 
            ind_both = np.where( ind_lay & ind_col )

            emp_layer_data[int(lc)].append( data_feat[ ind_both ] )


        for g in range(1, len(emp_layer_data)): 
            emp_layer_data[g] = np.concatenate(emp_layer_data[g]).flatten().tolist()


        for g in range(1, len(null_layer_data)): 
            if null_layer_data[g] == []: 
                null_layer_data[g] = [0]
        for g in range(1, len(emp_layer_data)): 
            if emp_layer_data[g] == []: 
                emp_layer_data[g] = [0] 

        colors = ['blue','red']

        fig = figure()
        ax = axes()

        # first boxplot pair
        bp = ax.boxplot([null_layer_data[1], emp_layer_data[1]], positions = [1, 2], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        scipy.wi




        # second boxplot pair
        bp = boxplot([null_layer_data[2], emp_layer_data[2]], positions = [4, 5], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        # thrid boxplot pair
        bp = boxplot([null_layer_data[3], emp_layer_data[3]], positions = [7, 8], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        bp = boxplot([null_layer_data[4], emp_layer_data[4]], positions = [10, 11], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        # second boxplot pair
        bp = boxplot([null_layer_data[5], emp_layer_data[5]], positions = [13, 14], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        # thrid boxplot pair
        bp = boxplot([null_layer_data[6], emp_layer_data[6]], positions = [16, 17], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        bp = boxplot([null_layer_data[7], emp_layer_data[7]], positions = [19, 20], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        # second boxplot pair
        bp = boxplot([null_layer_data[8], emp_layer_data[8]], positions = [22, 23], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        # thrid boxplot pair
        bp = boxplot([null_layer_data[9], emp_layer_data[9]], positions = [25, 26], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)

        bp = boxplot([null_layer_data[10], emp_layer_data[10]], positions = [28, 29], widths = 0.6)
        for patch, color in zip(bp['boxes'], colors):
            patch.set(color=color)




        # set axes limits and labels
        #xlim(0,10)
        #ylim(-5,5)
        ax.set_xticks([0, 29.5])
        ax.set_xticklabels(['CSF', 'WM'])

        # draw temporary red and blue lines and use them to create a legend
        hB, = plot([1,1],'b-')
        hR, = plot([1,1],'r-')
        legend((hB, hR),('NULL', 'VASO'))
        hB.set_visible(False)
        hR.set_visible(False)







        tit = "{}-{}".format(k, uc) 
        plt.title(tit )

        #ax.set_xticks([1,10])
        #ax.set_xticklabels(['CSF','WM'])


        plt.ylabel('beta weights')

        plt.savefig(plot_dir+"/{}.box3.png".format(tit))
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
