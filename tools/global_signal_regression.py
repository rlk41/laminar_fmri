#!/usr/bin/env python

import argparse
import pandas as pd 
import numpy as np 

import nibabel as nib
from nilearn.input_data import NiftiMasker
from statsmodels.formula.api import ols


from sklearn.preprocessing import normalize
from sklearn import linear_model

from nilearn.masking import apply_mask

from scipy import signal 
import scipy.stats as sp 

import os




def get_residual(X, Y):

    
    data = pd.DataFrame({'X':X,'Y':Y})
    res = ols('X ~ Y', data).fit()
    y_int = res.params[0]
    slope = res.params[1]

    X_out = [ ( ( slope * X[i] ) + y_int ) for i in range(X.shape[0])]
    Y_out = [  Y[i] - X_out[i] for i in range(len(X_out))]


    return Y_out


def regress_out_global_signal(mask_path, epi_path): 

    '''
    mask_path="/data/kleinrl/ds003216/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/warped_brain.scaled.bin.nii.gz"
    epi_path="/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.scaled.nii"
    
    mask_path="/data/kleinrl/ds003216/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/warped_brain.bin.nii.gz"
    epi_path="/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.nii"
    prefix="/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.gsr.nii.gz"
    '''

    # SEED ROI
    #masker                  = NiftiMasker(mask_img=mask_path) 
    #masker_epi              = masker.fit_transform(epi_path)
    #masker_epi_mean         = np.mean(masker_epi, 1)

    mask        = nib.load(mask_path)
    epi         = nib.load(epi_path)

    # if np.any(mask.affine != epi.affine): 
    #     print('affines dont match')
    #     return 



    mask_data           = mask.get_fdata()
    mask_ind            = np.where(mask_data == 1)

    epi_data            = epi.get_fdata()
    epi_brain_ts        = epi_data[mask_ind]
    epi_brain_ts_mean   = np.mean(epi_brain_ts,0)

    print(epi_brain_ts.shape)

    #out_data    = epi_data.copy()
    out_data    = np.zeros(shape=epi_data.shape)

    mask_len = len(mask_ind[0]) 

    for i in range(mask_len):
        x,y,z               = mask_ind[0][i], mask_ind[1][i], mask_ind[2][i]
        epi_regress         = epi_data[x,y,z]
        residual            = get_residual(epi_brain_ts_mean, epi_regress)
        out_data[x,y,z]     = residual


    out = nib.Nifti1Image(out_data, epi.affine, epi.header)

    return out



if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='regressLayers')
    parser.add_argument('--mask', type=str)
    parser.add_argument('--epi', type=str)
    parser.add_argument('--prefix', type=str)

    args    = parser.parse_args()

    mask_path   = args.mask
    epi_path    = args.epi
    prefix      = args.prefix 
    
    """
    mask_path="/data/kleinrl/ds003216/sub-01/ses-01/anat/sub-01_ses-01_run-01_T1w_working_recon-all/sub-01_ses-01_run-01_T1w/LAYNII_sub-01_ses-06_task-movie_run-05_VASO/warped_brain.bin.nii.gz"
    epi_path="/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.nii"
    prefix="/data/kleinrl/ds003216/derivatives/sub-01/VASO_func/sub-01_ses-06_task-movie_run-05_VASO.gsr.nii.gz"
  
    """

    epi_gsr = regress_out_global_signal(mask_path, epi_path)

    nib.save(epi_gsr, prefix)
