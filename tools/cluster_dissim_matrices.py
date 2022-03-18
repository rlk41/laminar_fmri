#!/usr/bin/env python

import pandas as pd
from glob import glob
import numpy as np
import argparse
import os
from sklearn.metrics.pairwise import cosine_similarity, cosine_distances, paired_cosine_distances
from scipy import stats






if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='build dataframe profile')
    parser.add_argument('--nii', type=str, nargs='+')
    parser.add_argument('--layers', type=list, default=None)
    parser.add_argument('--columns', type=str, default='none')
    parser.add_argument('--savedir', type=str)

    args = parser.parse_args()

    '''
    nii="/data/kleinrl/Wholebrain2.0/VASO_LN.4dmean.WITHOUT_D1R1.nii"
    columns="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/columns/columns_ev_10000_borders.nii"
    layers="/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT/LAYNII_2/layers/rim_equidist_n10_layers_equidist.nii"
    '''

    paths = args.nii
    rois = args.layers
    type = args.columns
    save_path  = args.savedir