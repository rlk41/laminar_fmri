import os
import numpy as np
import nibabel as nib
from glob import glob
import time
import pandas as pd
import argparse
import matplotlib.pyplot as plt


def generate_neural_dissimilarity_matrix(file):

    # file='/mnt/9c288662-e3a3-4d3f-b859-eb0521c7da77/ts_numpy_extract/1114.L_FOP3.L10.npy'

    mat    = np.load(file)
    mat_shape1 = mat.shape[1]
    out = np.zeros(shape=(mat_shape1,mat_shape1))
    for x in range(mat_shape1):
        for y in range(x,mat_shape1):
            out[x,y] = np.corrcoef(mat[:,x], mat[:,y])[0,1]

    o = np.triu(out,1).T + out

    fig, ax = plt.subplots(1,1)
    plt.imshow(o)
    plt.savefig("{}.dissimilarity.png".format(file))
    plt.close(fig=fig)


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='extract_ts')
    parser.add_argument('--file', type=str)
    #parser.add_argument('--id_roi', type=int)
    #parser.add_argument('--id_layer', type=int)

    args = parser.parse_args()

    # roi_name = 'L_V1'
    # id_roi = 1001
    # id_layer = 1

    #print(args.accumulate(args.integers))

    print("RUNNING: {}".format(args.file))

    generate_neural_dissimilarity_matrix(args.file)

    # ./extract_ts.py --roi_name 'L_V1' --id_roi 1001 --id_layer 1