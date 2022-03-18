#!/usr/bin/env python

from ctypes import c_char
import os
from numpy.lib.function_base import corrcoef
import argparse
import numpy as np
import matplotlib.pyplot as plt
import pylab
import nibabel as nib 
from nilearn.input_data import NiftiLabelsMasker
import pickle 

from nilearn import plotting


"""
plot_mosaic.py --input "inv_thresh_zstat1.fwhm3.nii.gz" --bg "inv_mean_func.nii"

"""


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--input', type=str)
    parser.add_argument('--bg', type=str)

    parser.add_argument('--mode', type=str, default='mosaic')
    parser.add_argument('--cc', type=int, default=15)

    args = parser.parse_args()

    path_input      = args.input
    mode            = args.mode
    bg              = args.bg 
    cc              = args.cc 





    """
    dir="/data/kleinrl/Wholebrain2.0/fsl_feat_permute_1010.L_FEF/mean/"

    path_input=dir+"/inv_thresh_zstat1.fwhm8.L2D.columns_ev_30000_borders.downscaled2x_NN.ratio.nii.gz"
    
    path_input=dir+"/inv_thresh_zstat1.fwhm3.nii.gz"

        bg=dir+"inv_mean_func.nii"

    """

    # plotting.plot_stat_map(path_input, display_mode='z', cut_coords=5,
    #                     title="display_mode='z', cut_coords=5")    

    out_file= path_input.rstrip('.nii.gz')+"."+mode+".png"

    plotting.plot_stat_map(path_input, bg_img=bg, 
                        display_mode=mode,
                        cut_coords=cc, output_file=out_file) 
