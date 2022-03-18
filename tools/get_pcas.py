#!/usr/bin/env python

from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import PCA
import argparse
import numpy as np 


def get_pcas(data):
 

    scaler = MinMaxScaler()

    data_rescaled = scaler.fit_transform(data)

    pca = PCA(n_components = 0.99)
    pca.fit(data_rescaled)
    reduced = pca.transform(data_rescaled)
    
    return reduced 


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='build dataframe profile')
    parser.add_argument('--file', type=str)
    args = parser.parse_args()

    print("LOADING DATA FROM: {}".format(args.file))

    # filename = "/data/kleinrl/Wholebrain2.0/fsl_feats/timeseries/both.LGN.dump"
    # filename = "/data/NIMH_scratch/kleinrl/analyses/FEF/1010.L_FEF_pca10/timeseries/DAY1_run1_VASO_LN.2D"
    filename = args.file
    filename_base = filename.split('/')[-1] #.rstrip('.dump')

    data = np.loadtxt(filename) 
    data_t = data.T

    reduced = get_pcas(data_t)

    for col in range(reduced.shape[1]): 
        np.savetxt(
            "{}.pca_{:03d}.1D".format(filename_base,col),
            reduced[:,col])


    print('DONE')