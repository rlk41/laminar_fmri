#!/usr/bin/env python


import argparse
import numpy as np
from random import randint





if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    parser.add_argument('--input', type=str)

    args = parser.parse_args()

    path_input      = args.input



    '''
    path_input      = "/data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_1010.L_FEF_pca10_ALL/timeseries/DAY2_run3_VASO_LN.2D"

    '''

    d = np.loadtxt(path_input)
    o = np.zeros(shape=d.shape)

    dimx, dimy = d.shape 

    for dx in range(dimx): 
        r = randint(0, dimy)
        o[dx,:] = np.concatenate((d[dx, r:], d[dx, :r]), axis=0)

    np.savetxt(path_input+".perm", o, fmt='%.6f')
'''
2D_rotate_timeseries.py --input /data/NIMH_scratch/kleinrl/analyses/nullDist_pca10_single/fsl_feat_1010.L_FEF_pca10_ALL/DAY2_run3_VASO_LN.2D
'''