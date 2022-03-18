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

import glob 


# fsl_feat_1010.L_FEF_pca10_NULL0000/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy

base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"

# nulls=glob.glob(base_dir+"/*NULL*/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")
# l=glob.glob(base_dir+"fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")

nulls   = glob.glob(base_dir+"/*NULL*/mean/inv_pe1.fwhm7.equi_volume_layers_n10.*hcp-mmp-b_rmap.scaled2x*.means.npy")
l       = glob.glob(base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.equi_volume_layers_n10.*hcp-mmp-b_rmap.scaled2x*.means.npy")

data_nulls = [] 
for n in nulls: 
    nn = np.load(n)

    data_nulls.append(nn) 

# NULLS 
y = [] 
for d in data_nulls: 
    y = np.flip(d[10,:]) 
    x = np.array([ x for x in range(0, y.shape[0] )])
    plt.plot(x, y, color='blue')

# FEAT 
d = np.load(l[0])

y = np.flip(d[10,:]) 
x = np.array([ x for x in range(0, y.shape[0] )])
plt.plot(x, y, color='red')



plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF/plots"
plt.savefig(plot_dir+"/FEF_NULL.png")







############################
############################

# fsl_feat_1010.L_FEF_pca10_NULL0000/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy

base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"

# nulls=glob.glob(base_dir+"/*NULL*/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")
# l=glob.glob(base_dir+"fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")

nulls   = glob.glob(base_dir+"/*NULL*/mean/inv_pe1.fwhm7.equi_volume_layers_n10.*hcp-mmp-b_rmap.scaled2x*.means.npy")
l       = glob.glob(base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.equi_volume_layers_n10.*hcp-mmp-b_rmap.scaled2x*.means.npy")

data_nulls = [] 
for n in nulls: 
    nn = np.load(n)

    data_nulls.append(nn) 

# NULLS 
y = [] 
for d in data_nulls: 
    y = np.flip(d[10,:]) 
    x = np.array([ x for x in range(0, y.shape[0] )])
    plt.plot(x, y, color='blue')

# FEAT 
d = np.load(l[0])

y = np.flip(d[10,:]) 
x = np.array([ x for x in range(0, y.shape[0] )])
plt.plot(x, y, color='red')

plt.title('L_FEF')

plot_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF/plots"
plt.savefig(plot_dir+"/FEF_NULL.png")




#############################













# fsl_feat_1010.L_FEF_pca10_NULL0000/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy

base_dir="/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_FEF"

# nulls   = glob.glob(base_dir+"/fsl_feat_*NULL*/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")
# l       = glob.glob(base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")

# nulls   = glob.glob(base_dir+"/fsl_feat_*NULL*/mean/inv_pe1.fwhm7.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")
# l       = glob.glob(base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.L2D.columns_ev_30000_borders.downscaled2x_NN.nii.gz")


data_nulls = [] 
for n in nulls: 
    nn = np.load(n)
    data_nulls.append(nn) 










plt.boxplot(data, notch=None, vert=None, patch_artist=None, widths=None)


keys = {'L_FEF':10,     'L_LIPv':48,    'L_VIP':9,      'L_V4t':156,    'R_V4':186,
        'R_V2':184,     'R_V3':185,     'L_V1':1,       'L_MST':2,      'L_MT':23,
        'L_TF':135,     'L_TE1a':132,   'L_TE1p':133,   'L_TE2a':134,   'L_TE2p':136,
        'L_FST':157 }


columns             = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii"
parc                = "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/multiAtlasTT/hcp-mmp-b/hcp-mmp-b_rmap.scaled2x.nii.gz"
nulls_3d            = ""
feat_3d             = ""
nulls_npy           = ""
feat_npy            = ""
img_parc            = nib.load(parc)
img_col             = nib.load(columns)

data_parc           = img_parc.get_fdata()
data_columns        = img_col.get_fdata()

nulls   = glob.glob(base_dir+"/fsl_feat_*NULL*/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")
l       = glob.glob(base_dir+"/fsl_feat_1010.L_FEF_pca10/mean/inv_pe1.fwhm7.equi_volume_layers_n10.columns_ev_30000_borders.means.npy")

data_nulls = [] 
for n in nulls: 
    nn = np.load(n)
    data_nulls.append(nn) 



for k in keys.keys(): 

    # k = 'L_FEF'
    ind_roi     = np.where(data_parc == keys[k] )

    unq_roi_col = np.unique(data_columns[ind_roi]) 
    unq_roi_col = [ uc for uc in unq_roi_col if uc != 0 ]

    for uc in unq_roi_col: 
        # uc = unq_roi_col[0]
        #ind_col = np.where(data_columns == uc)

        uc = int(uc) 

        # NULLS 
        y = [] 
        for d in data_nulls: 
            y = np.flip(d[uc,:]) 
            x = np.array([ x for x in range(0, y.shape[0] )])
            plt.plot(x, y, color='blue')

        # FEAT 
        d = np.load(l[0])

        y = np.flip(d[uc,:]) 
        x = np.array([ x for x in range(0, y.shape[0] )])
        plt.plot(x, y, color='red')

        tit = "{} - {}".format(k, uc) 
        plt.title(tit )
        plt.savefig(plot_dir+"/{}.png".format(tit))
        plt.close()
